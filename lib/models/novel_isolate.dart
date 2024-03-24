import 'dart:isolate';

enum NovelIsolateAction {
  setSendPort,
  setPercentage,
  saveDownloadedChapters,
  generateEPUB,
  cancel,
  done,
}

class NovelIsolate {
  final Isolate isolate;
  final ReceivePort rPort;
  SendPort? sPort;
  double downloadPercentage = 0.0;
  bool cancel = false;

  NovelIsolate({required this.isolate, required this.rPort});
}
