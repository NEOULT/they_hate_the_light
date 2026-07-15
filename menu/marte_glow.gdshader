shader_type canvas_item;

// Glow rojizo para la atmósfera de Marte
uniform float intensidad_glow : hint_range(0.0, 3.0, 0.05) = 1.0;
uniform float radio_glow : hint_range(1.0, 10.0, 0.5) = 4.0;
uniform vec3 color_glow : source_color = vec3(1.0, 0.4, 0.1);  // Naranja/rojo
uniform float velocidad_pulso : hint_range(0.0, 3.0, 0.1) = 0.8;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec2 texel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
    
    // Pulsación suave del glow
    float pulso = 0.8 + sin(TIME * velocidad_pulso) * 0.2;
    
    // Muestrear píxeles vecinos para crear glow
    vec3 glow_acumulado = vec3(0.0);
    float peso_total = 0.0;
    
    for (int x = -8; x <= 8; x++) {
        for (int y = -8; y <= 8; y++) {
            float fx = float(x);
            float fy = float(y);
            float dist = length(vec2(fx, fy));
            
            if (dist > radio_glow) continue;
            
            vec2 offset = vec2(fx, fy) * texel_size;
            vec4 muestra = texture(TEXTURE, UV + offset);
            
            // El glow viene de los bordes (donde alpha es bajo)
            float alpha_muestra = muestra.a;
            float peso = exp(-dist * 0.6) * (1.0 - alpha_muestra);
            
            glow_acumulado += color_glow * peso;
            peso_total += peso;
        }
    }
    
    // Aplicar glow en los bordes
    if (peso_total > 0.001) {
        float fuerza = peso_total * intensidad_glow * pulso * 0.15;
        color.rgb += glow_acumulado * fuerza;
    }
    
    COLOR = color;
}
