import fs from 'node:fs/promises';
import {SpreadsheetFile,FileBlob} from '@oai/artifact-tool';
const d='D:/mv/outputs/employee-pay-01a0b1e1';
for(const [src,dst,vi] of [['MV_Manufacturing_Bang_Luong_Hoan_Chinh.xlsx','MV_Manufacturing_Theo_Doi_Luong_Don_Gian.xlsx',true],['MV_Manufacturing_Payroll_English.xlsx','MV_Manufacturing_Simple_Payment_Tracker.xlsx',false]]){
 const w=await SpreadsheetFile.importXlsx(await FileBlob.load(`${d}/${src}`));
 const s=w.worksheets.getItemAt(0);
 s.getRange('E8:F8').clear({applyTo:'all'});
 s.getRange('C8').values=[[vi?'Đơn giá tăng ca':'OT rate']];
 s.getRange('A27:H38').unmerge();
 s.getRange('A27:H38').clear({applyTo:'all'});
 w.recalculate();
 console.log((await w.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?',options:{useRegex:true,maxResults:10}})).ndjson);
 const p=await w.render({sheetName:s.name,range:'A1:H28',scale:1});await fs.writeFile(`${d}/simple-${vi?'vi':'en'}.png`,new Uint8Array(await p.arrayBuffer()));
 await(await SpreadsheetFile.exportXlsx(w)).save(`${d}/${dst}`);
}
