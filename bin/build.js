const fs = require('fs');
const saxon = require('saxon-js');
const path = require('path');
const exec = require('await-exec');
const langs = ['es', 'en'];


const baseDir = (() => {
    const d = path.dirname(__filename);
    return d ? path.resolve(path.join(d, '..')) : path.resolve('..');
})();

async function generateHTML(lang) {
    console.log("===> Generating HTML...");
    const { stdout, stderr } = await exec(
        `npx xslt3 -t -s:${baseDir}/src/cv.xml -xsl:${baseDir}/src/cv.xsl -o:${baseDir}/dist/cv.${lang}.html lang=${lang}`
    );

    if (stderr)
        console.error(stderr);

    if (stdout)
        console.log(stdout);

    console.log("===> PDF generated.");
}

async function generatePDF(lang) {
    console.log("===> Generating PDF using commandline `electron-pdf`...");

    const { stdout, stderr } = await exec(
        `npx electron-pdf ${baseDir}/dist/cv.${lang}.html ${baseDir}/dist/cv.${lang}.pdf`
    );

    if (stderr)
        console.error(stderr);

    if (stdout)
        console.log(stdout);

    console.log("===> PDF generated.");
}

async function build() {
    for (let lang of langs) {
        console.log(`==> Processing language: ${lang}`);
        await generateHTML(lang);        
        await generatePDF(lang);
    };
}

build()
    .then(() => {})
    .catch(console.error);
