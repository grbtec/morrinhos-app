List splitList<T> (List<T> list, int sublistLength) {
  final sublists = [];
  for (int i = 0; i < list.length; i += sublistLength) {
    int tamanhoAtual = i + sublistLength;
    if (tamanhoAtual > list.length) {
      tamanhoAtual = list.length;
    }
    sublists.add(list.sublist(i, tamanhoAtual));
  }
  return sublists;
}
