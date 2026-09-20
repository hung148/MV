import fs from 'node:fs/promises';
import {SpreadsheetFile,FileBlob} from '@oai/artifact-tool';
const dir='D:/mv/outputs/employee-pay-01a0b1e1';
const w=await SpreadsheetFile.importXlsx(await FileBlob.load(`${dir}/MV_Manufacturing_Bang_Luong_Tieng_Viet.xlsx`));
const s=w.worksheets.getItemAt(0);
for(const table of [...s.tables.items])table.delete();
for(let n=11;n<=25;n++){
 const right=s.getRange(`H${n}`).values[0][0];
 if(right!==null&&right!==undefined&&right!=='')throw Error(`H${n} contains data`);
 s.mergeCells(`G${n}:H${n}`);
 s.getRange(`G${n}:H${n}`).format.fill=n===11?'#123C60':'#FFF2CC';
}
w.recalculate();
const p=await w.render({sheetName:s.name,range:'F10:H26',scale:1.5});
await fs.writeFile(`${dir}/merged-notes.png`,new Uint8Array(await p.arrayBuffer()));
await(await SpreadsheetFile.exportXlsx(w)).save(`${dir}/MV_Manufacturing_Bang_Luong_Tieng_Viet_Merged.xlsx`);
console.log('Merged G:H separately for header and all 14 daily rows.');
