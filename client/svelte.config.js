import preprocess from 'svelte-preprocess';
import makeAttractionsImporter from "attractions/importer.js";
import path from "path";
const __dirname = path.resolve();

/** @type {import('@sveltejs/kit').Config} */
const config = {
    // Consult https://github.com/sveltejs/svelte-preprocess
    // for more information about preprocessors
    preprocess: preprocess({
        scss: {
            importer: makeAttractionsImporter({
                // specify the path to your theme file, relative to this file
                themeFile: path.join(__dirname, 'static/css/theme.scss'),
            }),
            // not mandatory but nice to have for concise imports
            includePaths: [path.join(__dirname, './static/css')],
        },
    }),
    kit: {
        // hydrate the <div id="svelte"> element in src/app.html
        target: '#svelte'
    }
};

export default config;