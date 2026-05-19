const fs = require('fs');
const { readFile, writeFile } = require('fs/promises')
const path = require('path');
const exec = require('await-exec');
const cheerio = require('cheerio')
const marked = require('marked')
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

function unindent(text) {
    const tl = text.length;
    let il = 0;

    for (let i=0; i<tl; ++i) {
        if (['\n', '\r'].includes(text[i])) {
            il = 0
            continue;
        }

        if(' ' != text[i])
            break

        ++il;
    }

    return text
        .replace(RegExp(`(^|[\\n|\\r]+)([ ]{${il}})`, 'gms'), '\n')
        .trim()
}

async function transformHTML(lang) {
    console.log(`==> [${lang}] Transforming HTML...`);

    htmlPath = `${baseDir}/dist/cv.${lang}.html`;
    html = await readFile(htmlPath);

    const $ = cheerio.load(html);
    $('.project').each((i, e) => {
        $(e).html(marked.parse(unindent($(e).text())).replace(/<(\/?)p>/gm, ''))
    })

    await writeFile(htmlPath, $.html())
    console.log(`==> [${lang}] HTML transformed and saved`);
}

async function build() {
    console.log(`=> Processing languages: ${langs.join(', ')}`);
    await Promise.all(
        langs.map(async lang => {
            await generateHTML(lang);
            await transformHTML(lang);
            await generatePDF(lang);
        })
    );
}

build()
    .then(() => {})
    .catch(console.error);
