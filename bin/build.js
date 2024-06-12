const fs = require('fs');
const saxon = require('saxon-js');
const path = require('path');
const exec = require('await-exec');
const langs = ['es', 'en'];


const baseDir = (() => {
    const d = path.dirname(__filename);
    return d ? path.resolve(path.join(d, '..')) : path.resolve('..');
})();

async function runCommand(command) {
    const { stdout, stderr } = await exec(command);

    if (stderr)
        console.error(stderr);

    if (stdout)
        console.log(stdout);
}    

async function generateHTML(lang) {
    console.log(`==> [${lang}] Generating HTML using \`saxon-js\`...`);
    await runCommand(
        `npx xslt3 -t -s:${baseDir}/src/cv.xml -xsl:${baseDir}/src/cv.xsl -o:${baseDir}/dist/cv.${lang}.html lang=${lang}`
    );
    console.log(`==> [${lang}] HTML generated.`);
}

async function generatePDF(lang) {
    console.log(`==> [${lang}] Generating using \`electron-pdf\`...`);

    await runCommand(
        `npx electron-pdf ${baseDir}/dist/cv.${lang}.html ${baseDir}/dist/cv.${lang}.pdf`
    );

    console.log(`==> [${lang}] PDF generated.`);
}

async function build() {
    console.log(`=> Processing languages: ${langs.join(', ')}`);
    await Promise.all(
        langs.map(async lang => {
            await generateHTML(lang);        
            await generatePDF(lang);
        })
    );
}

build()
    .then(() => {})
    .catch(console.error);
