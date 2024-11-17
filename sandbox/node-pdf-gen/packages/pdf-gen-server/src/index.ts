import fs from "fs";
import path from "path";
import puppeteer from "puppeteer";
import { PDFDocument } from "pdf-lib";

const outputDir = path.resolve("./output");
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
  console.log(`Created output directory: ${outputDir}`);
}

const getNextFileName = (dir: string, baseName: string, ext: string) => {
  const files = fs.readdirSync(dir).filter((file) => file.startsWith(baseName) && file.endsWith(ext));
  const numbers = files.map((file) => {
    const match = file.match(new RegExp(`${baseName}(\\d+)${ext}$`));
    return match ? parseInt(match[1], 10) : 0;
  });
  const nextNumber = numbers.length > 0 ? Math.max(...numbers) + 1 : 1;
  return `${baseName}${nextNumber}${ext}`;
};

const addMetadataToPDF = async (pdfPath: string) => {
  const existingPdfBytes = fs.readFileSync(pdfPath);

  const pdfDoc = await PDFDocument.load(existingPdfBytes);

  pdfDoc.setTitle("Sample PDF Title");
  pdfDoc.setAuthor("Your Name");
  pdfDoc.setSubject("PDF Metadata Test");
  pdfDoc.setKeywords(["example", "pdf", "metadata"]);
  pdfDoc.setProducer("node-pdf-app");
  pdfDoc.setCreationDate(new Date());
  pdfDoc.setModificationDate(new Date());

  const modifiedPdfBytes = await pdfDoc.save();
  fs.writeFileSync(pdfPath, modifiedPdfBytes);
};

const generatePDF = async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  const targetURL = "http://localhost:3000";
  console.log(`Accessing URL: ${targetURL}`);

  try {
    await page.goto(targetURL, {
      waitUntil: "networkidle0",
    });

    const pdfFileName = getNextFileName(outputDir, "sample", ".pdf");
    const pdfPath = path.join(outputDir, pdfFileName);

    await page.pdf({
      path: pdfPath,
      format: "A4",
      printBackground: true,
      displayHeaderFooter: true,
      headerTemplate: `
        <style>
          #header {
            padding: 0 !important;
          }
          .header {
            font-size: 14px;
            text-align: center;
            color: white;
            background-color: #4CAF50;
            width: 100%;
            padding: 10px 0;
            -webkit-print-color-adjust: exact;
          }
        </style>
        <div class="header">
          Custom Header | <span class="title"></span>
        </div>
      `,
      footerTemplate: `
        <style>
          #footer{
            padding: 0 !important;
          }
          .footer {
            font-size: 14px;
            text-align: center;
            color: white;
            background-color: #4CAF50;
            width: 100%;
            padding: 10px 0;
            -webkit-print-color-adjust: exact;
          }
        </style>
        <div class="footer">
          Page <span class="pageNumber"></span> of <span class="totalPages"></span> | Custom Footer
        </div>
      `,
      margin: {
        top: "40px",
        bottom: "40px",
      }
    });

    console.log(`PDF has been saved to: ${pdfPath}`);

    await addMetadataToPDF(pdfPath);

    console.log(`Metadata added to: ${pdfFileName}`);
  } catch (error) {
    console.error("Error generating PDF with metadata:", error);
  } finally {
    await browser.close();
  }
};

generatePDF().catch((error) => {
  console.error("Error generating PDF:", error);
});
