import 'dart:typed_data';

import 'package:html/parser.dart' as html_parser;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Servicio para convertir HTML a PDF
class PdfService {
  /// Convierte HTML a PDF con mejor renderizado
  static Future<Uint8List> htmlToPdf(String htmlContent) async {
    try {
      // Limpiar el HTML: remover DOCTYPE, html, head si existen
      String cleanHtml = htmlContent;
      if (cleanHtml.contains('<!DOCTYPE')) {
        cleanHtml = cleanHtml.substring(cleanHtml.indexOf('<html'));
      }
      if (cleanHtml.contains('<html')) {
        final htmlEnd = cleanHtml.indexOf('</html>');
        if (htmlEnd != -1) {
          cleanHtml = cleanHtml.substring(0, htmlEnd);
        }
      }
      if (cleanHtml.contains('<head')) {
        final headStart = cleanHtml.indexOf('<head');
        final headEnd = cleanHtml.indexOf('</head>');
        if (headStart != -1 && headEnd != -1) {
          cleanHtml = cleanHtml.substring(0, headStart) + cleanHtml.substring(headEnd + 7);
        }
      }
      if (cleanHtml.contains('<body')) {
        final bodyStart = cleanHtml.indexOf('<body');
        final bodyTagEnd = cleanHtml.indexOf('>', bodyStart);
        if (bodyStart != -1 && bodyTagEnd != -1) {
          cleanHtml = cleanHtml.substring(bodyTagEnd + 1);
        }
      }
      if (cleanHtml.contains('</body>')) {
        cleanHtml = cleanHtml.substring(0, cleanHtml.indexOf('</body>'));
      }
      
      // Envolver en un div si no tiene un elemento raíz
      if (!cleanHtml.trim().startsWith('<')) {
        cleanHtml = '<div>$cleanHtml</div>';
      }
      
      final document = html_parser.parse(cleanHtml);
      final body = document.body ?? document.documentElement;

      if (body == null) {
        throw Exception('No se pudo parsear el HTML');
      }

      final pdf = pw.Document();
      final widgets = <pw.Widget>[];

      // Extraer contenido recursivamente desde el body o el elemento raíz
      _processElement(body, widgets);

      if (widgets.isEmpty) {
        throw Exception('No se pudo extraer contenido del HTML');
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return widgets;
          },
        ),
      );

      return pdf.save();
    } catch (e) {
      print('Error al generar PDF: $e');
      print('Stack trace: ${e.toString()}');
      rethrow;
    }
  }

  /// Procesa un elemento HTML recursivamente
  static void _processElement(dynamic element, List<pw.Widget> widgets) {
    if (element == null) return;

    final tagName = element.localName?.toLowerCase() ?? '';
    
    // Ignorar elementos script, style, head
    if (tagName == 'script' || tagName == 'style' || tagName == 'head') {
      return;
    }

    switch (tagName) {
      case 'h1':
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 20, bottom: 10),
            child: pw.Text(
              _getTextContent(element),
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        );
        break;

      case 'h2':
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 16, bottom: 8),
            child: pw.Text(
              _getTextContent(element),
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
          ),
        );
        break;

      case 'h3':
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 12, bottom: 6),
            child: pw.Text(
              _getTextContent(element),
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue600,
              ),
            ),
          ),
        );
        break;

      case 'p':
        final text = _getTextContent(element);
        if (text.trim().isNotEmpty) {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Text(
                text,
                style: const pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.justify,
              ),
            ),
          );
        } else {
          // Si no hay texto directo, procesar hijos (por si hay strong u otros elementos)
          _processChildren(element, widgets);
        }
        break;

      case 'ul':
      case 'ol':
        final items = <String>[];
        for (var li in element.children) {
          if (li.localName?.toLowerCase() == 'li') {
            items.add(_getTextContent(li));
          }
        }
        if (items.isNotEmpty) {
          widgets.add(
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10, left: 20),
              child: pw.Bullet(
                text: items.join('\n'),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          );
        }
        break;

      case 'table':
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 15),
            child: _buildTable(element),
          ),
        );
        break;

      case 'div':
        // Procesar contenido del div recursivamente
        final style = element.attributes['style'] ?? '';
        
        // Verificar si es un div contenedor principal (con margin/padding general y bg gris claro)
        if (style.contains('background-color: #f3f4f6') || 
            style.contains('background-color:#f3f4f6')) {
          // Es el contenedor principal - procesar hijos directamente
          _processChildren(element, widgets);
        } 
        // Verificar si es un bloque destacado (incidencias/riesgos) - tiene border-left y bg amarillo
        else if ((style.contains('border-left') || style.contains('borderLeft')) && 
                 (style.contains('#fff3cd') || style.contains('#f59e0b') || 
                  style.contains('background-color') && style.contains('yellow'))) {
          final content = <pw.Widget>[];
          _processChildren(element, content);
          
          if (content.isNotEmpty) {
            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber50,
                  border: pw.Border(
                    left: pw.BorderSide(
                      color: PdfColors.amber700,
                      width: 4,
                    ),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: content,
                ),
              ),
            );
          }
        }
        // Verificar si es un contenedor de barra de progreso
        else if ((style.contains('background-color: #e5e7eb') || 
                  style.contains('background-color:#e5e7eb')) &&
                 style.contains('border-radius')) {
          // Buscar dentro de este div: strong (texto) y div (barra)
          final progressContent = _extractProgressContent(element);
          if (progressContent != null) {
            widgets.add(progressContent);
          } else {
            _processChildren(element, widgets);
          }
        }
        // Verificar si es la barra de progreso misma (div interno con width y bg verde)
        else if (style.contains('width:') && 
                 (style.contains('background-color: #10b981') || 
                  style.contains('background-color:#10b981'))) {
          // Este es el div de la barra - no procesarlo aquí, se procesa desde el padre
          // Solo extraer el porcentaje si es necesario
          return; // No añadir nada, se maneja desde el padre
        }
        // Div normal - procesar hijos
        else {
          _processChildren(element, widgets);
        }
        break;

      default:
        // Para otros elementos, procesar hijos recursivamente
        _processChildren(element, widgets);
        break;
    }
  }

  /// Procesa los hijos de un elemento
  static void _processChildren(dynamic element, List<pw.Widget> widgets) {
    if (element == null) return;
    
    // Primero, verificar si hay nodos de texto directos
    final directText = StringBuffer();
    for (var node in element.nodes) {
      if (node.nodeType == 3) { // Text node
        final text = node.text?.trim() ?? '';
        if (text.isNotEmpty) {
          directText.write(text);
          directText.write(' ');
        }
      }
    }
    
    // Si hay texto directo y no es un elemento contenedor, añadirlo
    final directTextStr = directText.toString().trim();
    if (directTextStr.isNotEmpty && 
        !_isContainerElement(element.localName) &&
        element.children.isEmpty) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            directTextStr,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      );
      return;
    }
    
    // Procesar hijos recursivamente
    if (element.children.isNotEmpty) {
      for (var child in element.children) {
        _processElement(child, widgets);
      }
    } else if (directTextStr.isNotEmpty && 
               !_isContainerElement(element.localName)) {
      // Si no tiene hijos pero tiene texto, añadirlo
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            directTextStr,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      );
    }
  }

  /// Verifica si un elemento es contenedor (no debe mostrar su texto directo)
  static bool _isContainerElement(String? tagName) {
    if (tagName == null) return false;
    final containerTags = ['div', 'table', 'ul', 'ol', 'body', 'html'];
    return containerTags.contains(tagName.toLowerCase());
  }

  /// Obtiene el contenido de texto de un elemento
  static String _getTextContent(dynamic element) {
    if (element == null) return '';
    
    // Si es un elemento de texto directo
    if (element.text != null) {
      return element.text?.trim() ?? '';
    }
    
    // Si tiene hijos, obtener texto de todos los hijos que no sean elementos contenedores
    final buffer = StringBuffer();
    for (var node in element.nodes) {
      if (node.nodeType == 3) { // Text node
        buffer.write(node.text);
      } else if (node.localName != null) {
        final tagName = node.localName!.toLowerCase();
        if (!_isContainerElement(tagName) && 
            !['table', 'ul', 'ol', 'div'].contains(tagName)) {
          buffer.write(_getTextContent(node));
        }
      }
    }
    return buffer.toString().trim();
  }

  /// Extrae el contenido completo de una barra de progreso
  static pw.Widget? _extractProgressContent(dynamic containerElement) {
    String? progressText;
    int? percentage;
    
    // Buscar en todos los hijos del contenedor
    for (var child in containerElement.children) {
      final tagName = child.localName?.toLowerCase() ?? '';
      
      // Buscar el texto en strong o p
      if (tagName == 'strong' || tagName == 'p') {
        final text = _getTextContent(child);
        if (text.contains('%') || 
            text.toLowerCase().contains('avance') ||
            text.toLowerCase().contains('porcentaje')) {
          progressText = text.trim();
          // Extraer el porcentaje del texto
          final percentMatch = RegExp(r'(\d+)%').firstMatch(text);
          if (percentMatch != null) {
            percentage = int.tryParse(percentMatch.group(1)!);
          }
        }
      }
      
      // Buscar el div con la barra de progreso
      if (tagName == 'div') {
        final style = child.attributes['style'] ?? '';
        if (style.contains('width:') && 
            (style.contains('#10b981') || style.contains('green'))) {
          final widthMatch = RegExp(r'width:\s*(\d+)%').firstMatch(style);
          if (widthMatch != null) {
            percentage = int.tryParse(widthMatch.group(1)!);
          }
        }
      }
    }
    
    // Si encontramos al menos el porcentaje, crear el widget
    if (percentage != null) {
      final progressChildren = <pw.Widget>[];
      
      if (progressText != null && progressText.isNotEmpty) {
        progressChildren.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(
              progressText,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
      }
      
      // Crear la barra de progreso
      progressChildren.add(
        pw.Container(
          height: 20,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Stack(
            children: [
              pw.Container(
                width: double.infinity,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
              ),
              pw.Container(
                width: (PdfPageFormat.a4.width - 80) * (percentage / 100),
                height: 20,
                decoration: pw.BoxDecoration(
                  color: PdfColors.green600,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      );
      
      // Procesar el resto del contenido (como párrafos después de la barra)
      final remainingContent = <pw.Widget>[];
      bool foundProgressBar = false;
      for (var child in containerElement.children) {
        if (foundProgressBar) {
          _processElement(child, remainingContent);
        }
        final tagName = child.localName?.toLowerCase() ?? '';
        if (tagName == 'div') {
          final style = child.attributes['style'] ?? '';
          if (style.contains('width:') && style.contains('#10b981')) {
            foundProgressBar = true;
          }
        }
      }
      progressChildren.addAll(remainingContent);
      
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: progressChildren,
      );
    }
    
    return null;
  }

  /// Construye una tabla desde un elemento table HTML
  static pw.Widget _buildTable(dynamic tableElement) {
    final rows = <pw.TableRow>[];
    bool isHeader = true;

    for (var tr in tableElement.children) {
      if (tr.localName?.toLowerCase() != 'tr') continue;

      final cells = <pw.Widget>[];
      bool isHeaderRow = false;

      for (var cell in tr.children) {
        final cellTag = cell.localName?.toLowerCase();
        if (cellTag != 'td' && cellTag != 'th') continue;

        if (cellTag == 'th') {
          isHeaderRow = true;
        }

        final cellText = _getTextContent(cell);
        cells.add(
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              cellText,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: cellTag == 'th'
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
                color: cellTag == 'th' ? PdfColors.blue900 : PdfColors.black,
              ),
            ),
          ),
        );
      }

      if (cells.isNotEmpty) {
        if (isHeader && isHeaderRow) {
          rows.add(
            pw.TableRow(
              children: cells,
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
            ),
          );
          isHeader = false;
        } else {
          rows.add(pw.TableRow(children: cells));
        }
      }
    }

    if (rows.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
      },
      children: rows,
    );
  }

  /// Muestra el PDF usando printing
  static Future<void> showPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
