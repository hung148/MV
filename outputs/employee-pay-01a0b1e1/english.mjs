import fs from 'node:fs/promises';
import {SpreadsheetFile,FileBlob} from '@oai/artifact-tool';
const d='D:/mv/outputs/employee-pay-01a0b1e1';
const w=await SpreadsheetFile.importXlsx(await FileBlob.load(`${d}/MV_Manufacturing_Bang_Luong_Hoan_Chinh.xlsx`));
const original=await SpreadsheetFile.importXlsx(await FileBlob.load('C:/Users/ASUS/Downloads/MV_Manufacturing_Biweekly_Payroll.xlsx'));
for(let i=0;i<2;i++){
 const s=w.worksheets.getItemAt(i), o=original.worksheets.getItemAt(i);
 const rows=i===0?38:111,cols=i===0?8:14;
 for(let row=0;row<rows;row++)for(let col=0;col<cols;col++){
  const cell=o.getCell(row,col),v=cell.values[0][0],formula=cell.formulas[0][0];
  if(formula){if((i===0&&col===1&&row>=11&&row<=24)||(i===1&&col===9&&row>=11))s.getCell(row,col).formulas=[[formula]];}
  else if(typeof v==='string'&&v!=='')s.getCell(row,col).values=[[v]];
 }
}
const f=w.worksheets.getItemAt(0),r=w.worksheets.getItemAt(1);
const methods=['Direct deposit','Check','Cash','Other'];
f.getRange('B36').dataValidation={rule:{type:'list',values:methods}};
r.getRange('L12:L111').dataValidation={rule:{type:'list',values:methods}};
r.getRange('J12:J111').conditionalFormats.clear();
for(const [text,fill]of [['Unpaid','#FFDAD6'],['Partial','#FFF2CC']])r.getRange('J12:J111').conditionalFormats.add('containsText',{text,format:{fill}});
for(const a of ['B7','D7','F7','F36','A12:A25'])f.getRange(a).setNumberFormat('mm/dd/yyyy');
for(const a of ['B12:C111','K12:K111'])r.getRange(a).setNumberFormat('mm/dd/yyyy');
w.recalculate();
console.log((await w.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#NUM!',options:{useRegex:true,maxResults:10}})).ndjson);
for(const [s,range,n]of [[f,'A1:H38','english-form'],[r,'A1:N16','english-register']]){const p=await w.render({sheetName:s.name,range,scale:1});await fs.writeFile(`${d}/${n}.png`,new Uint8Array(await p.arrayBuffer()));}
await(await SpreadsheetFile.exportXlsx(w)).save(`${d}/MV_Manufacturing_Payroll_English.xlsx`);
console.log('English version saved with matching merged layout.');
