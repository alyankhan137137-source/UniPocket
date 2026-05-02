import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class PdfGenerator {
  static Future<void> generateExpenseReport({
    required List<Expense> expenses,
    required DateTimeRange dateRange,
    required String userName,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    
    // Calculate summaries
    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> categoryTotals = {};

    for (var e in expenses) {
      if (e.isIncome) {
        totalIncome += (e.amount / 100.0);
      } else {
        totalExpense += (e.amount / 100.0);
        categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + (e.amount / 100.0);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(userName, dateRange, dateFormat),
          pw.SizedBox(height: 20),
          _buildSummary(totalIncome, totalExpense, expenses.length),
          pw.SizedBox(height: 20),
          _buildCategoryBreakdown(categoryTotals),
          pw.SizedBox(height: 20),
          _buildTransactionTable(expenses, dateFormat),
          _buildFooter(context),
        ],
      ),
    );

    // Save and Share
    try {
      if (kIsWeb) {
        debugPrint("PDF export not supported on web yet.");
        return;
      }
      // Mobile only
      final bytes = await pdf.save();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, name: 'Expense_Report.pdf', mimeType: 'application/pdf')],
          text: 'My Expense Report',
        ),
      );
    } catch (e) {
      debugPrint("Error generating PDF: $e");
    }
  }

  static pw.Widget _buildHeader(String name, DateTimeRange range, DateFormat df) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('PocketTrack Lite', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
            pw.Text('Expense Report', style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('${df.format(range.start)} - ${df.format(range.end)}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(double income, double expense, int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Income', '\$${income.toStringAsFixed(2)}', PdfColors.green),
          _summaryItem('Expense', '\$${expense.toStringAsFixed(2)}', PdfColors.red),
          _summaryItem('Balance', '\$${(income - expense).toStringAsFixed(2)}', (income - expense) >= 0 ? PdfColors.blue : PdfColors.red),
          _summaryItem('Count', '$count', PdfColors.grey),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  static pw.Widget _buildCategoryBreakdown(Map<String, double> categories) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Category Breakdown', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Category', 'Amount'],
          data: categories.entries.map((e) => [e.key, '\$${e.value.toStringAsFixed(2)}']).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
          cellAlignment: pw.Alignment.centerLeft,
          cellAlignments: {1: pw.Alignment.centerRight},
        ),
      ],
    );
  }

  static pw.Widget _buildTransactionTable(List<Expense> expenses, DateFormat df) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Transactions', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Date', 'Title', 'Category', 'Type', 'Amount'],
          data: expenses.map((e) => [
            df.format(e.date),
            e.title,
            e.category,
            e.type.toUpperCase(),
            '${e.isIncome ? '+' : '-'}\$${(e.amount / 100.0).toStringAsFixed(2)}'
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellAlignment: pw.Alignment.centerLeft,
          cellAlignments: {4: pw.Alignment.centerRight},
          rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 32),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
      ),
    );
  }
}
