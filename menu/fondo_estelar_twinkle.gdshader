shader_type canvas_item;

// Parámetros principales
uniform float velocidad : hint_range(0.0, 5.0, 0.1) = 1.5;
uniform float intensidad : hint_range(0.0, 3.0, 0.05) = 1.2;
uniform float umbral_brillo : hint_range(0.0, 0.5, 0.01) = 0.1;
uniform float radio_glow : hint_range(1.0, 8.0, 0.5) = 3.0;
uniform float intensidad_glow : hint_range(0.0, 2.0, 0.05) = 1.0;

// Función para crear un hash único basado en posición
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float brillo_base = max(color.r, max(color.g, color.b));
    
    // Calcular parpadeo basado en posición única de cada estrella
    vec2 pos_estrella = UV * 150.0;
    float seed = hash(floor(pos_estrella));
    
    // Ondas sinusoidales variadas para parpadeo natural
    float onda1 = sin(TIME * velocidad * 2.0 + seed * 6.2831 * 3.0);
    float onda2 = sin(TIME * velocidad * 3.7 + seed * 6.2831 * 7.0 + 1.5);
    float onda3 = sin(TIME * velocidad * 1.3 + seed * 6.2831 * 2.0 + 3.0);
    
    float parpadeo = onda1 * 0.5 + 0.5;
    parpadeo = mix(parpadeo, onda2 * 0.5 + 0.5, 0.3);
    parpadeo = mix(parpadeo, onda3 * 0.5 + 0.5, 0.2);
    parpadeo = smoothstep(0.2, 0.8, parpadeo);
    
    // === EFECTO GLOW: (simplificado temporalmente para diagnóstico) ===
    // El glow loop se comentó para descartar problemas de rendimiento/compilación
    
    // === PARPADEO DIRECTO para estrellas brillantes ===
    if (brillo_base > umbral_brillo) {
        float factor_brillo = 1.0 + parpadeo * intensidad * 0.5;
        color.rgb *= factor_brillo;
        
        // Tinte sutil (azul o cálido)
        float tinte = sin(seed * 6.2831) * 0.5 + 0.5;
        vec3 tinte_frio = vec3(0.8, 0.9, 1.2);
        vec3 tinte_calido = vec3(1.2, 1.1, 0.8);
        vec3 tinte_color = mix(tinte_frio, tinte_calido, tinte);
        color.rgb = mix(color.rgb, color.rgb * tinte_color, 0.15 * parpadeo);
    }
    
    // Usamos COLOR directamente, modulate se aplica automáticamente por el engine
    COLOR = color;
}
