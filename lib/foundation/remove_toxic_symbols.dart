String removeToxicSymbols(String string) {
  return string
      .replaceAll('Container.', '')
      .replaceAll(r'\', '')
      .replaceAll('/', '')
      .replaceAll('*', '')
      .replaceAll('?', '')
      .replaceAll('"', '')
      .replaceAll('<', '')
      .replaceAll('>', '')
      .replaceAll('|', '')
      .replaceAll(':', '')
      .replaceAll('!', '')
      .replaceAll('[', '')
      .replaceAll(']', '')
      .replaceAll('¡', '');
}
