class BrickParticle{
  double x, y;
  double vx, vy;
  double life;

  BrickParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
  });

  void update(double dt) {
    x += vx * dt * 160;
    y += vy * dt * 160;
    life -= dt * 2;
  }
}