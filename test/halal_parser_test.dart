import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Next.js stream unescaping and JSON array bracket extraction test', () {
    const rawPush = r'self.__next_f.push([1,"4e:[\"$\",\"$L4f\",null,{\"data\":[{\"id\":\"123\",\"nama_produk\":\"Wardah Cushion\",\"merek_dagang\":\"WARDAH\",\"sertifikat\":{\"no_sertifikat\":\"ID00410000070950920\",\"tgl_terbit_sertifikat\":\"02 November 2026\"},\"pelaku_usaha\":{\"nama_pelaku_usaha\":\"PT PARAGON\"},\"pabrik\":[{\"nama\":\"Pabrik Tangerang\",\"alamat\":\"Jl. Industri No 1\",\"kab_kota\":\"TANGERANG\"}]}],\"currentPage\":1,\"totalItems\":45,\"pageSize\":10,\"totalPages\":5}]"])';

    final pushRegex = RegExp(r'self\.__next_f\.push\(\[1,\s*"(.*?)"\]\)', dotAll: true);
    final match = pushRegex.firstMatch(rawPush);
    expect(match, isNotNull);

    final inner = match!.group(1)!;
    final unescaped = inner
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', r'\')
        .replaceAll(r'\n', '\n');

    final dataIdx = unescaped.indexOf('"data":[');
    expect(dataIdx, isNot(-1));

    final start = dataIdx + 7;
    int count = 0;
    int end = start;
    for (int i = start; i < unescaped.length; i++) {
      if (unescaped[i] == '[') {
        count++;
      } else if (unescaped[i] == ']') {
        count--;
        if (count == 0) {
          end = i + 1;
          break;
        }
      }
    }

    final arrayStr = unescaped.substring(start, end);
    final items = jsonDecode(arrayStr) as List<dynamic>;
    expect(items.length, 1);
    expect(items[0]['nama_produk'], 'Wardah Cushion');
    expect(items[0]['sertifikat']['no_sertifikat'], 'ID00410000070950920');

    final totalItemsMatch = RegExp(r'"totalItems":\s*(\d+)').firstMatch(unescaped);
    final totalPagesMatch = RegExp(r'"totalPages":\s*(\d+)').firstMatch(unescaped);
    expect(totalItemsMatch?.group(1), '45');
    expect(totalPagesMatch?.group(1), '5');
  });
}
