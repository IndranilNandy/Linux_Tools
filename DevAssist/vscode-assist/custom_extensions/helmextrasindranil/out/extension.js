'use strict';
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deactivate = exports.activate = void 0;
const vscode = require("vscode");
const k8s = require("vscode-kubernetes-tools-api");
// import { ungzip } from 'node-gzip';
const path = require("path");
const fs = require("fs");
const child_process_1 = require("child_process");
const zlib = require("zlib");
const YAML = require("json-to-pretty-yaml");
// const YAML = require('json-to-pretty-yaml');
const HELMPREVIEW_SUFFIX = '.helmpreview';
const templatePreviewTextEditorCache = {};
const templatetHelmPreviewFileCache = {};
const MANIFEST = 'Manifest';
const TEMPLATES = 'Templates';
const VALUES = 'Values';
const NOTES = 'Notes';
const HOOKS = 'Hooks';
const CHART = 'Chart';
const INFO = 'Info';
const RAW = 'Raw';
const GET_TYPES = [
    MANIFEST,
    TEMPLATES,
    VALUES,
    NOTES,
    HOOKS,
    CHART,
    INFO,
    RAW
];
function activate(context) {
    return __awaiter(this, void 0, void 0, function* () {
        const explorer = yield k8s.extension.clusterExplorer.v1;
        if (!explorer.available) {
            vscode.window.showErrorMessage(`ClusterExplorer not available.`);
            return;
        }
        const helm = yield k8s.extension.helm.v1;
        if (!helm.available) {
            vscode.window.showErrorMessage(`helm not available.`);
            return;
        }
        let disposable;
        disposable = vscode.commands.registerTextEditorCommand('k8s.helm.helmTemplatePreview.custom', helmTemplatePreview);
        context.subscriptions.push(disposable);
        // Helm get
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.manifest', helmGetManifest);
        context.subscriptions.push(disposable);
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.manifest.selected', helmGetManifestSelected);
        context.subscriptions.push(disposable);
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.templates', helmGetTemplates);
        context.subscriptions.push(disposable);
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.templates.selected', helmGetTemplatesSelected);
        context.subscriptions.push(disposable);
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.values', helmGetValues);
        context.subscriptions.push(disposable);
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.notes', helmGetNotes);
        context.subscriptions.push(disposable);
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.hooks', helmGetHooks);
        context.subscriptions.push(disposable);
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.hooks.selected', helmGetHooksSelected);
        context.subscriptions.push(disposable);
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.chart', helmGetChart);
        context.subscriptions.push(disposable);
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.info', helmGetInfo);
        context.subscriptions.push(disposable);
        disposable = vscode.commands.registerCommand('k8s.helm.release.revision.get.some', helmGetSome);
        context.subscriptions.push(disposable);
        vscode.window.visibleTextEditors;
        disposable = vscode.window.onDidChangeVisibleTextEditors((e) => {
            Object.keys(templatePreviewTextEditorCache).forEach(key => {
                const cachedEditor = templatePreviewTextEditorCache[key];
                if (vscode.window.visibleTextEditors.findIndex(te => te === cachedEditor) === -1) {
                    delete templatePreviewTextEditorCache[key];
                    delete templatetHelmPreviewFileCache[key];
                }
            });
        });
        context.subscriptions.push(disposable);
        const fileSystemWatcher = vscode.workspace.createFileSystemWatcher("**/*.{yml,yaml}", true, false, true);
        fileSystemWatcher.onDidChange(templateChanged);
        context.subscriptions.push(fileSystemWatcher);
        setTimeout(() => __awaiter(this, void 0, void 0, function* () {
            const rv = yield vscode.commands.executeCommand('workbench.view.extension.extension.vsKubernetesExplorer');
        }), 5000);
    });
}
exports.activate = activate;
function templateChanged(changeEvent) {
    return __awaiter(this, void 0, void 0, function* () {
        const templateFilePath = changeEvent.fsPath;
        Object.keys(templatePreviewTextEditorCache).forEach(fsPath => {
            // Is the template being previewed ?
            if (templateFilePath.endsWith(fsPath)) {
                vscode.window.visibleTextEditors.forEach(textEditor => {
                    // Find the text editor for the template
                    if (textEditor.document.uri.fsPath === templateFilePath) {
                        helmTemplatePreview(textEditor);
                    }
                });
            }
        });
    });
}
function helmTemplatePreview(editor) {
    return __awaiter(this, void 0, void 0, function* () {
        const templateFilePath = editor.document.uri.fsPath;
        if (vscode.workspace.workspaceFolders && vscode.workspace.workspaceFolders[0]) {
            let folder = path.dirname(templateFilePath);
            while (isDirectory(folder)) {
                if (isFile(path.join(folder, 'Chart.yaml'))) {
                    const templateFile = path.relative(folder, templateFilePath);
                    let helmpreviewFilePath = templatetHelmPreviewFileCache[templateFile];
                    if (!helmpreviewFilePath) {
                        const helmpreviewFilePathsMap = {};
                        const files = fs.readdirSync(folder);
                        files.forEach(file => {
                            const filePath = path.join(folder, file);
                            if (isFile(filePath) && file.endsWith(HELMPREVIEW_SUFFIX)) {
                                if (file === HELMPREVIEW_SUFFIX) {
                                    helmpreviewFilePathsMap[HELMPREVIEW_SUFFIX] = filePath;
                                }
                                else {
                                    helmpreviewFilePathsMap[file.replace(/\.helmpreview$/, '')] = filePath;
                                }
                            }
                        });
                        helmpreviewFilePath = path.join(folder, '.helmpreview');
                        const keys = Object.keys(helmpreviewFilePathsMap);
                        if (keys.length === 1) {
                            helmpreviewFilePath = helmpreviewFilePathsMap[keys[0]];
                        }
                        else if (keys.length > 1) {
                            const helmpreview = yield vscode.window.showQuickPick(keys, {
                                placeHolder: `Select ${HELMPREVIEW_SUFFIX} profile to use for preview`
                            });
                            if (helmpreview) {
                                helmpreviewFilePath = helmpreviewFilePathsMap[helmpreview];
                            }
                            else {
                                return;
                            }
                        }
                        else {
                            return;
                        }
                    }
                    if (isFile(helmpreviewFilePath)) {
                        let templateCommand = fs.readFileSync(helmpreviewFilePath, {
                            encoding: 'utf8'
                        });
                        templateCommand = templateCommand.split(/\r?\n/g).join(' ');
                        const helm = yield k8s.extension.helm.v1;
                        if (!helm.available) {
                            return;
                        }
                        const helmProcess = (0, child_process_1.exec)(`${templateCommand} --show-only ${templateFile}`, {
                            cwd: folder
                        }, (error, templatePreview, stderr) => __awaiter(this, void 0, void 0, function* () {
                            if ((error) && !(stderr.includes("YAML parse error"))) {
                                vscode.window.showErrorMessage(stderr);
                            }
                            else {
                                if (stderr.includes("YAML parse error")) {
                                    vscode.window.showErrorMessage(stderr);
                                }
                                let templatePreviewTextEditorInThisGo = false;
                                let templatePreviewTextEditor = templatePreviewTextEditorCache[templateFile];
                                if (templatePreviewTextEditor === undefined) {
                                    // Open the document
                                    let templatePreviewDocument = yield vscode.workspace.openTextDocument({
                                        language: 'yaml',
                                        content: ''
                                    });
                                    templatePreviewTextEditor = yield vscode.window.showTextDocument(templatePreviewDocument, vscode.ViewColumn.Beside);
                                    templatePreviewTextEditorInThisGo = true;
                                }
                                if (!templatePreviewTextEditorInThisGo) {
                                    // Remove from cache
                                    delete templatePreviewTextEditorCache[templateFile];
                                    delete templatetHelmPreviewFileCache[templateFile];
                                }
                                templatePreviewTextEditor.edit(editBuilder => {
                                    // Put good templatePreviewTextEditor in cache
                                    templatePreviewTextEditorCache[templateFile] = templatePreviewTextEditor;
                                    templatetHelmPreviewFileCache[templateFile] = helmpreviewFilePath;
                                    const document = templatePreviewTextEditor.document;
                                    const fullRange = new vscode.Range(document.positionAt(0), document.positionAt(document.getText().length - 1));
                                    editBuilder.replace(fullRange, `${templatePreview}
# Preview generated using the following template command:
# ${templateCommand} --show-only ${templateFile}
# specified in file ${helmpreviewFilePath}.
`);
                                });
                                if (!templatePreviewTextEditorInThisGo) {
                                    let templatePreviewTextEditorFromCache = templatePreviewTextEditorCache[templateFile];
                                    if (templatePreviewTextEditorFromCache === undefined) {
                                        // Looks like the editor did not get put back in cache - was probably a closed editor
                                        // TODO: recreate - for now let user know
                                        vscode.window.showWarningMessage('Preview was closed. Invoke Preview Template (using .helmpreview) command again.');
                                    }
                                }
                                if (stderr) {
                                    console.error(stderr);
                                }
                            }
                        }));
                        // const templateShellResult = await helm.api.invokeCommand(`${templateCommand} --show-only ${templateFile}`);
                        // if (templateShellResult.code === 0) {
                        //     console.log(`${templateShellResult.stdout}\n# Generated using template command:\n# helm ${templateCommand} --show-only ${templateFile}\n`);
                        // }
                    }
                    else {
                        vscode.commands.executeCommand('extension.helmTemplatePreview');
                    }
                    break;
                }
                folder = path.dirname(folder);
            }
        }
    });
}
function helmGetManifest(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, [MANIFEST]);
    });
}
function helmGetManifestSelected(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, [MANIFEST], true);
    });
}
function helmGetTemplates(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, [TEMPLATES]);
    });
}
function helmGetTemplatesSelected(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, [TEMPLATES], true);
    });
}
function helmGetValues(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, [VALUES]);
    });
}
function helmGetNotes(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, [NOTES]);
    });
}
function helmGetHooks(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, [HOOKS]);
    });
}
function helmGetHooksSelected(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, [HOOKS], true);
    });
}
function helmGetChart(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, [CHART]);
    });
}
function helmGetInfo(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, [INFO]);
    });
}
function helmGetSome(target) {
    return __awaiter(this, void 0, void 0, function* () {
        helmGet(target, []);
    });
}
function helmGet(target, extractTypes, selected = false) {
    return __awaiter(this, void 0, void 0, function* () {
        const explorer = yield k8s.extension.clusterExplorer.v1;
        if (!explorer.available) {
            vscode.window.showErrorMessage(`ClusterExplorer not available.`);
            return;
        }
        const kubectl = yield k8s.extension.kubectl.v1;
        if (!kubectl.available) {
            vscode.window.showErrorMessage(`kubectl not available.`);
            return;
        }
        const helm = yield k8s.extension.helm.v1;
        if (!helm.available) {
            return;
        }
        if (target) {
            const commandTarget = explorer.api.resolveCommandTarget(target);
            if (commandTarget) {
                let namespace;
                const namespaceShellResult = yield kubectl.api.invokeCommand('config view --minify --output "jsonpath={..namespace}"');
                if (namespaceShellResult) {
                    if (namespaceShellResult.code === 0) {
                        namespace = namespaceShellResult.stdout.split(/\r?\n/g).join('');
                    }
                }
                let releaseName;
                let releaseRevision;
                if (commandTarget.nodeType === 'resource' && commandTarget.resourceKind.manifestKind === 'Secret') {
                    const secretName = commandTarget.name;
                    if (/sh\.helm\.release\.v\d+\..*.v\d+/.test(secretName)) {
                        const matches = secretName.match(/sh\.helm\.release\.v\d+\.(.*).v(\d)+/);
                        if (matches && matches.length === 3) {
                            releaseName = matches[1];
                            releaseRevision = matches[2];
                        }
                    }
                }
                else if (commandTarget.nodeType === 'helm.release') {
                    releaseName = commandTarget.name;
                    const historyShellResult = yield helm.api.invokeCommand(`history -o json ${releaseName}`);
                    if (historyShellResult.code === 0) {
                        const historyJson = JSON.parse(historyShellResult.stdout);
                        const revisions = historyJson.map((historyItem) => `${historyItem.revision}`).reverse();
                        const revision = yield vscode.window.showQuickPick(revisions, {
                            canPickMany: false,
                            placeHolder: 'Choose revision. 0 means latest'
                        });
                        if (!revision) {
                            return;
                        }
                        releaseRevision = revision;
                    }
                }
                else if (target.nodeType === 'helm.history') {
                    releaseName = target.releaseName;
                    releaseRevision = target.release.revision;
                }
                helmGetAllReleaseRevisionFromNamespace(releaseName, releaseRevision, namespace, extractTypes, selected);
            }
        }
    });
}
function helmGetAllReleaseRevisionFromNamespace(releaseName, releaseRevision, namespace, extractTypes = [], selected) {
    return __awaiter(this, void 0, void 0, function* () {
        const explorer = yield k8s.extension.clusterExplorer.v1;
        if (!explorer.available) {
            vscode.window.showErrorMessage(`ClusterExplorer not available.`);
            return;
        }
        const kubectl = yield k8s.extension.kubectl.v1;
        if (!kubectl.available) {
            vscode.window.showErrorMessage(`kubectl not available.`);
            return;
        }
        let helmGetExtractTypes;
        if (extractTypes.length > 0) {
            helmGetExtractTypes = extractTypes;
        }
        else {
            helmGetExtractTypes = yield vscode.window.showQuickPick(GET_TYPES, {
                canPickMany: true,
                placeHolder: 'Choose items for helm get ? release revision'
            });
        }
        if (!helmGetExtractTypes || helmGetExtractTypes.length === 0) {
            return;
        }
        const secretName = `sh.helm.release.v1.${releaseName}.v${releaseRevision}`;
        const shellResult = yield kubectl.api.invokeCommand(`get secret ${secretName} -o go-template="{{.data.release | base64decode }}" -n ${namespace}`);
        if (shellResult && shellResult.code === 0) {
            vscode.window.withProgress({
                location: vscode.ProgressLocation.Notification,
                title: `Getting ${selected ? 'selected ' : ''}[ ${helmGetExtractTypes.join(',')} ] from: Release: ${releaseName} Revision: ${releaseRevision}`
            }, (progress, token) => {
                return new Promise((resolve, reject) => {
                    zlib.gunzip(Buffer.from(shellResult.stdout, 'base64'), (e, inflated) => __awaiter(this, void 0, void 0, function* () {
                        if (e) {
                            reject(e);
                        }
                        else {
                            try {
                                const helmGetAllJSON = JSON.parse(inflated.toString('utf8'));
                                let notes = '';
                                let values = '';
                                let templates = '';
                                let manifests = '';
                                let hooks = '';
                                let chart = '';
                                let info = '';
                                notes = helmGetAllJSON.info.notes.split('\\n').join('\n');
                                helmGetAllJSON.chart.templates.forEach((template) => {
                                    const templateString = Buffer.from(template.data, 'base64').toString('utf-8');
                                    templates += `\n# Template: ${template.name}\n${templateString}\n# End Template: ${template.name}`;
                                });
                                templates = templates.split('\\n').join('\n');
                                if (helmGetAllJSON.config) {
                                    values += `# value overrides\n---\n${YAML.stringify(helmGetAllJSON.config)}`;
                                }
                                values += `# values\n---\n${YAML.stringify(helmGetAllJSON.chart.values)}`;
                                manifests = helmGetAllJSON.manifest.split('\\n').join('\n');
                                helmGetAllJSON.hooks.forEach((hook) => {
                                    hooks += `\n# Source: ${hook.path}\n${hook.manifest}\n---`;
                                });
                                hooks = hooks.split('\\n').join('\n');
                                helmGetAllJSON.chart.files.forEach((file) => {
                                    file.data = Buffer.from(file.data, 'base64').toString('utf-8');
                                });
                                chart = YAML.stringify(helmGetAllJSON.chart.metadata);
                                info = YAML.stringify(helmGetAllJSON.info);
                                if (helmGetExtractTypes.indexOf(RAW) !== -1) {
                                    // Open the get all document
                                    const helmGetAllDocument = yield vscode.workspace.openTextDocument({
                                        language: 'jsonc',
                                        content: `// helm get all ${releaseName} --revision ${releaseRevision} -n ${namespace}\n${JSON.stringify(helmGetAllJSON, null, '  ')}`
                                    });
                                    yield vscode.window.showTextDocument(helmGetAllDocument, vscode.ViewColumn.Active);
                                }
                                if (helmGetExtractTypes.indexOf(NOTES) !== -1) {
                                    // Open the get notes document
                                    const notesDocument = yield vscode.workspace.openTextDocument({
                                        language: 'plain',
                                        content: `# helm get notes ${releaseName} --revision ${releaseRevision} -n ${namespace}\n${notes}`
                                    });
                                    yield vscode.window.showTextDocument(notesDocument, vscode.ViewColumn.Active);
                                }
                                if (helmGetExtractTypes.indexOf(HOOKS) !== -1) {
                                    if (selected) {
                                        yield helmExtract(releaseName, releaseRevision, namespace, HOOKS, hooks.split('\n'), 'yaml');
                                    }
                                    else {
                                        // Open the get hooks document
                                        const hooksDocument = yield vscode.workspace.openTextDocument({
                                            language: 'yaml',
                                            content: `# helm get hooks ${releaseName} --revision ${releaseRevision} -n ${namespace}\n${hooks}`
                                        });
                                        yield vscode.window.showTextDocument(hooksDocument, vscode.ViewColumn.Active);
                                    }
                                }
                                if (helmGetExtractTypes.indexOf(CHART) !== -1) {
                                    // Open the get values document
                                    const valuesDocument = yield vscode.workspace.openTextDocument({
                                        language: 'yaml',
                                        content: `# helm get chart ${releaseName} --revision ${releaseRevision} -n ${namespace}\n${chart}`
                                    });
                                    yield vscode.window.showTextDocument(valuesDocument, vscode.ViewColumn.Active);
                                }
                                if (helmGetExtractTypes.indexOf(INFO) !== -1) {
                                    // Open the get values document
                                    const valuesDocument = yield vscode.workspace.openTextDocument({
                                        language: 'yaml',
                                        content: `# helm get info ${releaseName} --revision ${releaseRevision} -n ${namespace}\n${info}`
                                    });
                                    yield vscode.window.showTextDocument(valuesDocument, vscode.ViewColumn.Active);
                                }
                                if (helmGetExtractTypes.indexOf(VALUES) !== -1) {
                                    // Open the get values document
                                    const valuesDocument = yield vscode.workspace.openTextDocument({
                                        language: 'yaml',
                                        content: `# helm get values ${releaseName} --revision ${releaseRevision} -n ${namespace}\n${values}`
                                    });
                                    yield vscode.window.showTextDocument(valuesDocument, vscode.ViewColumn.Active);
                                }
                                if (helmGetExtractTypes.indexOf(TEMPLATES) !== -1) {
                                    if (selected) {
                                        yield helmExtract(releaseName, releaseRevision, namespace, TEMPLATES, templates.split('\n'), 'helm');
                                    }
                                    else {
                                        // Open the get templates document
                                        const templatesDocument = yield vscode.workspace.openTextDocument({
                                            language: 'helm',
                                            content: `# helm get templates ${releaseName} --revision ${releaseRevision} -n ${namespace}\n${templates}`
                                        });
                                        yield vscode.window.showTextDocument(templatesDocument, vscode.ViewColumn.Active);
                                    }
                                }
                                if (helmGetExtractTypes.indexOf(MANIFEST) !== -1) {
                                    if (selected) {
                                        yield helmExtract(releaseName, releaseRevision, namespace, MANIFEST, manifests.split('\n'), 'yaml');
                                    }
                                    else {
                                        // Open the get manifests document
                                        const manifestsDocument = yield vscode.workspace.openTextDocument({
                                            language: 'yaml',
                                            content: `# helm get manifest ${releaseName} --revision ${releaseRevision} -n ${namespace}\n${manifests}`
                                        });
                                        yield vscode.window.showTextDocument(manifestsDocument, vscode.ViewColumn.Beside);
                                    }
                                }
                            }
                            finally {
                                resolve(inflated);
                            }
                        }
                    }));
                });
            });
        }
        else {
            vscode.window.showErrorMessage(`Failed`);
        }
    });
}
function helmExtract(releaseName, releaseRevision, namespace, extractType, lines, languageId) {
    return __awaiter(this, void 0, void 0, function* () {
        const explorer = yield k8s.extension.clusterExplorer.v1;
        if (!explorer.available) {
            return;
        }
        const helm = yield k8s.extension.helm.v1;
        if (!helm.available) {
            return;
        }
        if (lines.length > 0) {
            const yamlFileToYamlMap = {};
            let yamlFile = undefined;
            let yamlLines = [];
            const startsWith = `# ${extractType === TEMPLATES ? 'Template: ' : 'Source: '}`;
            const endStartsWith = `${extractType === TEMPLATES ? '# End Template: ' : '---'}`;
            lines.forEach(line => {
                if (line.startsWith(endStartsWith)) {
                    if (yamlFile !== undefined) {
                        yamlFileToYamlMap[yamlFile] = yamlLines;
                    }
                    yamlFile = undefined;
                    yamlLines = [];
                }
                else if (line.startsWith(startsWith)) {
                    yamlFile = line.substring(startsWith.length);
                }
                else {
                    yamlLines.push(line);
                }
            });
            // Handle last
            if (yamlFile !== undefined) {
                yamlFileToYamlMap[yamlFile] = yamlLines;
            }
            yamlFile = undefined;
            yamlLines = [];
            const yamlFileNames = Object.keys(yamlFileToYamlMap);
            if (yamlFileNames.length === 0) {
                vscode.window.showInformationMessage(`No ${extractType} for release ${releaseName}.`);
                return;
            }
            const selected = yield vscode.window.showQuickPick(yamlFileNames, {
                // canPickMany: true,
                placeHolder: `Choose ${extractType} to load.`
            });
            if (selected) {
                const yamlText = [
                    `# ${selected} - ${extractType} Release: ${releaseName} Rivision: ${releaseRevision} Namespace: ${namespace}`,
                    `${startsWith}${selected}`,
                    '---',
                    ...yamlFileToYamlMap[selected]
                ].join('\n') + '\n';
                // vscode.env.clipboard.writeText(yamlText);
                // vscode.window.showInformationMessage(`Copied ${extractType} ${selected} for release ${releaseName} to clipboard.`);
                // Open the document
                let templatePreviewDocument = yield vscode.workspace.openTextDocument({
                    language: selected.endsWith('.txt') ? 'plaintext' : languageId,
                    content: yamlText
                });
                yield vscode.window.showTextDocument(templatePreviewDocument, vscode.ViewColumn.Active);
            }
        }
    });
}
function deactivate() {
}
exports.deactivate = deactivate;
function isFile(path) {
    if (fs.existsSync(path) && fs.statSync(path).isFile()) {
        return true;
    }
    return false;
}
function isDirectory(path) {
    if (fs.existsSync(path) && fs.statSync(path).isDirectory()) {
        return true;
    }
    return false;
}
//# sourceMappingURL=extension.js.map