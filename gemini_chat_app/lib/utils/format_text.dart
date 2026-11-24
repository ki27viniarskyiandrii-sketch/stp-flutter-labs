/// Базове форматування відповіді моделі:
/// прибираю пробіли в кінці рядків, зайві порожні рядки і пробіли по краях.
String formatModelText(String raw) {
  final lines = raw
      .replaceAll('\r\n', '\n')
      .split('\n')
      .map((line) => line.trimRight())
      .toList();
  return lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}
