// Lista de pontos de controle
ArrayList<Point> points = new ArrayList();

// Tamanho dos pontos de controle (raio)
float radius = 5.0;

// Tamanho dos pontos de Bézier (raio)
float bezierRadius = 1.0;

// Passo do parâmetro de interpolação (resolução da curva Bézier)
float step = 0.001;

// Índice de ponto de controle selecionado
int selection = -1;

// Deve desenhar linha de controle
boolean controlLine = true;

void setup() {
    // Configura tamanho da janela
    size(500, 500);
}

void draw() {
    // Configura plano de fundo para branco (limpa buffer de cor)
    background(255, 255, 255);
    
    // Desenha pontos de controle
    drawControlPoints();
    
    // Desenha linha de controle
    if (controlLine)
        drawControlLine();
        
    // Computa e desenha curva Bézier
    drawBezierCurve();
}

// Se alguma tecla é pressionada executa "callback keyPressed"
void keyPressed() {
    // Se tecla "c" é pressionada deleta todos os pontos de controle
    if (key == 'c')
        points.clear();
    // Se tecla "h" é pressionada ativa ou desativa visualização da linha de controle
    else if (key == 'h')
        controlLine = !controlLine;
}

void mousePressed() {
    // Verifica se existe algum ponto de controle sob o "mouse" e marca como seleção
    for (int i = 0; i < points.size(); i++) {
        Point point = points.get(i);
        
        // Verifica se a posição do "mouse" está sob algum dos pontos de controle existente
        if (point.overlaps(mouseX, mouseY)) {
            selection = i;
            break;
        }
    }
    
    // Se não exite adiciona novo ponto de controle na posição do "mouse"
    if (mouseButton == LEFT && selection == -1) {
        points.add(new Point(mouseX, mouseY, radius));
        selection = points.size() - 1;
    }
    // Remove ponto de controle selecionado sob a posição do "mouse"
    else if (mouseButton == RIGHT && selection != -1)
        points.remove(selection);
}

// Se algum botão do "mouse" é pressionado executa "callback mousePressed"
void mouseDragged() {
    // Move ponto de controle selecionado junto com a posição do "mouse"
    if (selection != -1) {
        Point point = points.get(selection);
        
        // Função "clamp" mantem os pontos dentro dos limites da janela
        point.x = clamp(mouseX, 0, width);
        point.y = clamp(mouseY, 0, height);
    }
}

// Se algum botão do "mouse" deixa de ser pressionado executa "callback mouseReleased"
void mouseReleased() {
    // Desmarca ponto de controle selecionado
    selection = -1;
}

// Restrição de valor escalar em intervalo
float clamp(float x, float a, float b) {
    return Math.min(Math.max(x, a), b);
}

// Interpolação linear de pontos
PVector lerp(PVector a, PVector b, float t) {
    return PVector.mult(a, 1.0 - t).add(PVector.mult(b, t));
}

// Algoritmo De Casteljau desenha curvas Bézier de qualquer grau (número de pontos de controle menos um)
// Este algoritmo retorna um ponto da curva Bézier interpolado pelo parâmetro "t"
PVector casteljau(int degree, int index, float t) {
    // Se a curva tem grau zero retorna o próprio ponto de controle
    if (degree == 0) {
        Point point = points.get(index);
        return new PVector(point.x, point.y);
    }

    // Se a curva tem grau maior que zero, encontra o par de pontos gerados pela interpolação de grau inferior
    PVector point0 = casteljau(degree - 1, index, t);
    PVector point1 = casteljau(degree - 1, index + 1, t);

    // Retorna ponto interpolado em função do parâmetro "t"
    return lerp(point0, point1, t);
}

// Desenha pontos de controle
void drawControlPoints() {
    for (Point point : points)
        point.draw();
}

// Desenha linha de controle
void drawControlLine() {
    for (int i = 0; i < points.size() - 1; i++) {
        Point p0 = points.get(i);
        Point p1 = points.get(i + 1);
        
        // Desenha linha entre pontos de controle
        line(p0.x, p0.y, p1.x, p1.y);
    }
}

// Desenha curva Bézier de grau igual ao número de pontos de controle menos um
void drawBezierCurve() {
    if (points.size() > 0) {
        for (float t = 0; t <= 1.0; t += step) {
            // Computa ponto Bézier recursivamente
            PVector point = casteljau(points.size() - 1, 0, t);

            // Desenha ponto Bézier
            Point p = new Point(point.x, point.y, bezierRadius);
            p.draw();
        }
    }
}
