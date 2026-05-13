import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

/// A utility class for generating and sharing Excel (.xlsx) financial reports.
class ExcelGenerator {
  /// Generates an Excel report for the given [expenses] and triggers a system share sheet.
  static Future<void> generateExcelReport({
    required List<Expense> expenses,
    required String userName,
  }) async {
    final excel = Excel.createExcel();
    const String sheetName = "All Transactions";
    excel.rename(excel.getDefaultSheet()!, sheetName);
    
    final Sheet sheet = excel[sheetName];
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    CellStyle headerStyle = CellStyle(
      bold: true,
      italic: false,
      fontFamily: getFontFamily(FontFamily.Arial),
      fontColorHex: ExcelColor.fromHexString("#FFFFFF"),
      backgroundColorHex: ExcelColor.fromHexString("#6C63FF"),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    CellStyle amountStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
    );

    List<String> headers = ["Date", "Type", "Category", "Title", "Amount", "Payment Method", "Note"];
    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    for (var i = 0; i < expenses.length; i++) {
      final e = expenses[i];
      final rowIndex = i + 1;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value = TextCellValue(dateFormat.format(e.date));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value = TextCellValue(e.type.toUpperCase());
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value = TextCellValue(e.category);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value = TextCellValue(e.title);
      var amountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex));
      amountCell.value = DoubleCellValue(e.amount / 100.0);
      amountCell.cellStyle = amountStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex)).value = TextCellValue(e.paymentMethod ?? "N/A");
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex)).value = TextCellValue(e.note ?? "");
    }

    const String summarySheetName = "Summary";
    excel.updateCell(summarySheetName, CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0), TextCellValue("Report Summary"), cellStyle: headerStyle);
    double totalIncome = expenses.where((e) => e.type == 'income').fold(0.0, (sum, e) => sum + (e.amount / 100.0));
    double totalExpense = expenses.where((e) => e.type == 'expense').fold(0.0, (sum, e) => sum + (e.amount / 100.0));
    excel.updateCell(summarySheetName, CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2), TextCellValue("Total Allowance/Added"));
    excel.updateCell(summarySheetName, CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2), DoubleCellValue(totalIncome));
    excel.updateCell(summarySheetName, CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3), TextCellValue("Total Expense"));
    excel.updateCell(summarySheetName, CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3), DoubleCellValue(totalExpense));
    excel.updateCell(summarySheetName, CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4), TextCellValue("Net Balance"));
    excel.updateCell(summarySheetName, CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4), DoubleCellValue(totalIncome - totalExpense));

    try {
      final List<int>? fileBytes = excel.save();
      if (fileBytes != null) {
        if (kIsWeb) {
          debugPrint("Excel export not supported on web yet.");
          return;
        }
        final uint8Bytes = Uint8List.fromList(fileBytes);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(uint8Bytes, name: 'UniPocket_Report.xlsx', mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
            text: 'UniPocket Expense Report (Excel)',
          ),
        );
      }
    } catch (e) {
      debugPrint("Error generating Excel: $e");
    }
  }
}
