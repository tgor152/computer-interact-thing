class MouseEvent {
  final DateTime timestamp;
  final int x;
  final int y;
  final String type; // 'move' or 'click'
  
  MouseEvent(this.timestamp, this.x, this.y, this.type);
}