import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import '../models/mouse_event.dart';

class ExportService {
  Future<String> exportToExcel(List<MouseEvent> events) async {
    final excel = Excel.createExcel();
    final sheet = excel['MouseEvents'];
    
    // Set cell values directly using updateCell instead of appendRow
    sheet.updateCell(CellIndex.indexByString('A1'), TextCellValue('Timestamp'));
    sheet.updateCell(CellIndex.indexByString('B1'), TextCellValue('X'));
    sheet.updateCell(CellIndex.indexByString('C1'), TextCellValue('Y'));
    sheet.updateCell(CellIndex.indexByString('D1'), TextCellValue('Type'));
    
    for (int i = 0; i < events.length; i++) {
      final e = events[i];
      final row = i + 2; // Start from row 2 (1-indexed)
      sheet.updateCell(CellIndex.indexByString('A$row'), TextCellValue(e.timestamp.toIso8601String()));
      sheet.updateCell(CellIndex.indexByString('B$row'), IntCellValue(e.x));
      sheet.updateCell(CellIndex.indexByString('C$row'), IntCellValue(e.y));
      sheet.updateCell(CellIndex.indexByString('D$row'), TextCellValue(e.type));
    }
    
    final downloadsPath = '${Platform.environment['USERPROFILE']}\\Downloads';
    final downloadsDir = Directory(downloadsPath);
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    final file = File('$downloadsPath/mouse_events.xlsx');
    await file.writeAsBytes(excel.encode()!);
    
    return file.path;
  }
}