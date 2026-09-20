import fs from 'node:fs/promises';
import {Workbook,SpreadsheetFile,FileBlob} from '@oai/artifact-tool';
const out='D:/mv/outputs/employee-pay-01a0b1e1';
const w=await SpreadsheetFile.importXlsx(await FileBlob.load('C:/Users/ASUS/Downloads/MV_Manufacturing_Biweekly_Payroll.xlsx'));
const f=w.worksheets.getItemAt(0),r=w.worksheets.getItemAt(1);
if(process.argv.includes('--inspect')){console.log((await w.inspect({kind:'sheet,drawing',maxChars:2000})).ndjson);for(const [s,range,n] of [[f,'A1:H38','before-form'],[r,'A1:N16','before-register']]){const p=await w.render({sheetName:s.name,range,scale:1.2});await fs.writeFile(`${out}/${n}.png`,new Uint8Array(await p.arrayBuffer()));}process.exit(0);}
const fm={C3:'PHIẾU THANH TOÁN LƯƠNG NHÂN VIÊN',A6:'Họ tên nhân viên',E6:'Mã nhân viên',A7:'Ngày bắt đầu',C7:'Ngày kết thúc',E7:'Ngày trả lương',G7:'Bộ phận / công việc',A8:'Lương giờ (USD)',C8:'Đơn giá tăng ca 1,5×',E8:'Đơn giá tăng ca 2×',G8:'Ngày đầu tuần làm việc',A10:'Nhập giờ đã duyệt dạng thập phân (7,5 = 7 giờ 30 phút), không tính giờ nghỉ không lương.',A11:'Ngày',B11:'Thứ',C11:'Giờ thường',D11:'Giờ tăng ca 1,5×',E11:'Giờ tăng ca 2×',F11:'Tổng giờ',G11:'Ghi chú công việc',A26:'TỔNG CỘNG',A28:'Số ngày làm việc',C28:'Lương giờ thường',E28:'Lương tăng ca 1,5×',G28:'Lương tăng ca 2×',A30:'Thu nhập khác đã duyệt (USD)',E30:'Gồm phụ cấp / nghỉ hưởng lương đã được duyệt.',A31:'TỔNG THU NHẬP',A32:'Thuế và khấu trừ (USD)',E32:'Nhập tổng từ bảng lương; nhập 0 nếu không có.',A33:'Hoàn trả chi phí (USD)',E33:'Khoản hoàn trả chi phí tách riêng với thu nhập.',A34:'THỰC LĨNH',E35:'Số tiền đã trả',G35:'Số tiền còn phải trả',A36:'Hình thức trả',E36:'Ngày đã trả',G36:'Mã giao dịch / số séc',A38:'Chữ ký nhân viên',E38:'Người duyệt / ngày duyệt'};
const rm={C3:'SỔ THEO DÕI THANH TOÁN LƯƠNG',A6:'Mỗi dòng cho một nhân viên trong một kỳ lương. Nhập số liệu đã chốt từ phiếu lương hoặc hồ sơ bảng lương.',A8:'Tổng thực lĩnh',D8:'Tổng đã trả',G8:'Tổng còn phải trả',A9:'Nhập 0 nếu không có khấu trừ / hoàn trả / tiền đã trả. Trạng thái chỉ phản ánh thanh toán, không phải phê duyệt bảng lương.',A11:'Họ tên nhân viên',B11:'Ngày bắt đầu',C11:'Ngày kết thúc',D11:'Tổng thu nhập',E11:'Thuế / khấu trừ',F11:'Hoàn trả chi phí',G11:'Thực lĩnh',H11:'Số tiền đã trả',I11:'Còn phải trả',J11:'Trạng thái',K11:'Ngày đã trả',L11:'Hình thức trả',M11:'Mã giao dịch / số séc',N11:'Ghi chú / mã nhân viên'};
for(const [s,map] of [[f,fm],[r,rm]])for(const [a,t]of Object.entries(map))s.getRange(a).values=[[t]];
for(let n=12;n<=25;n++)f.getRange(`B${n}`).formulas=[[`=IF(A${n}="","",CHOOSE(WEEKDAY(A${n}),"Chủ nhật","Thứ hai","Thứ ba","Thứ tư","Thứ năm","Thứ sáu","Thứ bảy"))`]];
const statuses={'Incomplete':'Thiếu thông tin','Overpaid':'Trả thừa','Unpaid':'Chưa trả','Partial':'Trả một phần','Add paid details':'Bổ sung thông tin trả','Paid':'Đã trả'};
for(let n=12;n<=111;n++){let q=r.getRange(`J${n}`).formulas[0][0];for(const [a,b]of Object.entries(statuses))q=q.replaceAll(`"${a}"`,`"${b}"`);r.getRange(`J${n}`).formulas=[[q]];}
const methods=['Chuyển khoản','Séc','Tiền mặt','Khác'];f.getRange('B36').dataValidation={rule:{type:'list',values:methods}};r.getRange('L12:L111').dataValidation={rule:{type:'list',values:methods}};
r.getRange('J12:J111').conditionalFormats.clear();for(const [text,fill]of [['Chưa trả','#FFDAD6'],['Trả một phần','#FFF2CC']])r.getRange('J12:J111').conditionalFormats.add('containsText',{text,format:{fill}});
for(const s of [f,r]){s.showGridLines=false;s.getUsedRange().format.font.name='Arial';s.getUsedRange().format.verticalAlignment='center';}
f.getRange('A1:H38').format.columnWidth=19;f.getRange('B1:B38').format.columnWidth=17;f.getRange('G1:H38').format.columnWidth=23;
f.getRange('A6:H8').format.wrapText=true;f.getRange('A6:H8').format.rowHeight=34;
f.getRange('A11:H11').format.rowHeight=34;f.getRange('A11:H11').format.wrapText=true;
f.getRange('A12:H25').format.rowHeight=25;f.getRange('A12:H25').format.borders={insideHorizontal:{style:'thin',color:'#DFE5EC'}};
for(const a of ['A28:H28','A35:H36','A38:H38']){f.getRange(a).format.wrapText=true;f.getRange(a).format.rowHeight=34;}
for(const a of ['A10:H10','E30:H30','E32:H33']){f.getRange(a).format.wrapText=true;f.getRange(a).format.rowHeight=30;}
f.getRange('C3').format.font.size=12;
for(const a of ['B7','D7','F7','F36','A12:A25'])f.getRange(a).setNumberFormat('dd/mm/yyyy');
r.getRange('A1:A111').format.columnWidth=25;r.getRange('D1:I111').format.columnWidth=19;r.getRange('J1:J111').format.columnWidth=26;r.getRange('L1:N111').format.columnWidth=23;r.getRange('A11:N11').format.wrapText=true;r.getRange('A11:N11').format.rowHeight=36;
for(const a of ['B12:C111','K12:K111'])r.getRange(a).setNumberFormat('dd/mm/yyyy');
w.recalculate();console.log((await w.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#NUM!',options:{useRegex:true,maxResults:20}})).ndjson);
for(const [s,range,n] of [[f,'A1:H38','vi-form'],[r,'A1:N16','vi-register']]){const p=await w.render({sheetName:s.name,range,scale:1.2});await fs.writeFile(`${out}/${n}.png`,new Uint8Array(await p.arrayBuffer()));}
await(await SpreadsheetFile.exportXlsx(w)).save(`${out}/MV_Manufacturing_Bang_Luong_Tieng_Viet.xlsx`);
console.log('Saved Vietnamese workbook');process.exit(0);
