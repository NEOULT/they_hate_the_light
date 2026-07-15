shader_type canvas_item;

// Glow dorado para Saturno
uniform float intensidad_glow : hint_range(0.0, 3.0, 0.05) = 1.2;
uniform float radio_glow : hint_range(1.0, 10.0, 0.5) = 5.0;
uniform float velocidad_pulso : hint_range(0.0, 3.0, 0.1) = 0.6;
uniform float brillo_anillos : hint_range(0.0, 2.0, 0.05) = 0.8;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec2 texel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
    
    // Pulsación suave del glow
    float pulso = 0.85 + sin(TIME * velocidad_pulso) * 0.15;
    
    // Detectar si es anillo (píxeles con alpha intermedio - translúcidos)
    float es_anillo = smoothstep(0.1, 0.5, color.a) * (1.0 - smoothstep(0.5, 0.9, color.a));
    
    // Brillo especial para anillos
    float factor_anillo = 1.0 + es_anillo * brillo_anillos * pulso;
    color.rgb *= factor_anillo;
    
    // Muestrear píxeles vecinos para crear glow dorado
    vec3 glow_acumulado = vec3(0.0);
    float peso_total = 0.0;
    
    for (int x = -6; x <= 6; x++) {
        for (int y = -6; y <= 6; y++) {
            float fx = float(x);
            float fy = float(y);
            float dist = length(vec2(fx, fy));
            
            if (dist > radio_glow) continue;
            
            vec2 offset = vec2(fx, fy) * texel_size;
            vec4 muestra = texture(TEXTURE, UV + offset);
            
            // Glow desde bordes del planeta y anillos
            float peso = exp(-dist * 0.5) * muestra.a;
            
            // Color dorado/ámbar
            glow_acumulado += vec3(1.0, 0.85, 0.4) * peso;
            peso_total += peso;
        }
    }
    
    // Aplicar glow dorado
    if (peso_total > 0.001) {
        float fuerza = peso_total * intensidad_glow * pulso * 0.12;
        color.rgb += glow_acumulado * fuerza;
    }
    
    COLOR = color;
}
