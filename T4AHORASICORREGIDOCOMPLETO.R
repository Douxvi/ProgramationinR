# ---
# TÍTULO: Proyecto 2 (Ejercicios 1, 2 y 3): Validación de Placas
# DESCRIPCIÓN: Script completo que define, explica y prueba
#              una expresión regular para placas de taxi.
# AUTOR: David Gael Osorio Del Olmo
# FECHA: 10/11/2025
# ---

# --- PASO 1: Cargar librerías ---
library(tidyverse)

# ---
# --- EJERCICIO 1 DE 4: CONSTRUIR LA EXPRESIÓN REGULAR ---
# ---

# Esta es la expresión regular que valida el formato de placa
regex_placa <- "^NY-(M|F|G)-(?!000)\\d{3}-[A-HJ-NP-Z]{2}$"
# --- Desglose de la Expresión Regular (Comentarios) ---
#
# ^                 # ANCLA DE INICIO: La placa debe empezar exactamente aquí.
# NY-               # PREFIJO: Debe ser el texto literal "NY-".
# (M|F|G)           # TIPO: Debe ser M, F, o G (usando alternación).
# -                 # SEPARADOR: Debe ser el texto literal "-".
# (?!000)           # NÚMERO (Validación 1): "Negative Lookahead".
#                   # Esto asegura que los siguientes 3 dígitos NO sean "000".
# \\d{3}            # NÚMERO (Validación 2): Debe haber exactamente 3 dígitos.
#                   # La combinación de (?!000) y \\d{3} valida el rango 001-999.
# -                 # SEPARADOR: Debe ser el texto literal "-".
# [A-HJ-NP-Z]{2}    # ZONA: Dos caracteres. La clase [A-HJ-NP-Z] significa:
#                   # "Cualquier letra mayúscula de A-Z, EXCEPTO I y O".
# $                 # ANCLA DE FIN: La placa debe terminar exactamente aquí.
#
# ---

# --- : Creación de datos de prueba ---

# Combinamos todos los ejemplos en un solo vector
placas_prueba <- c(
  "NY-M-245-ZK",  # Válido
  "NY-F-001-AB",  # Válido
  "NY-G-999-ZZ",  # Válido
  "-----------------", # Separador visual
  "NY-X-245-ZK",  # Inválido (tipo X)
  "NY-M-24-ZK",   # Inválido (2 dígitos)
  "NY-M-245-Z0",  # Inválido (zona con dígito)
  "ny-m-245-zk",  # Inválido (minúsculas)
  "NY-M-245-IO",  # Inválido (zona con I/O)
  "NY-G-000-AA",  # Inválido (número 000)
  "EXTRA: NY-M-123-BC" # Válido (para confirmar)
)

# --- : Aplicar la validación ---

# Usaremos 'str_detect()' de 'stringr' (tidyverse) que es muy clara.
# Creamos un tibble (un data frame moderno) para ver los resultados.
resultados_validacion <- tibble(
  Placa_Prueba = placas_prueba,
  Es_Valida = str_detect(Placa_Prueba, regex_placa)
)

# ---  Mostrar resultados en Consola ---

cat("--- PROYECTO 2: RESULTADOS DE VALIDACIÓN DE PLACAS ---\n\n")
print(resultados_validacion)
cat("\n")
# ---
# --- EJERCICIO 2 DE 4: EXPLICACIÓN DE LA EXPRESIÓN REGULAR ---
# ---

# ^ (Ancla de inicio):
#   Exige que la placa comience exactamente aquí. Evita coincidencias
#   parciales como "ABC-NY-M-123-AB".
#
# NY- (Literales):
#   Busca el texto exacto "NY-".
#
# (M|F|G) (Grupo con Alternación):
#   El paréntesis agrupa las opciones, y el | (pipe) significa "O".
#   Solo acepta 'M', 'F', o 'G'.
#
# - (Literal):
#   Busca el guion literal.
#
# (?!000) (Lookahead Negativo):
#   Esta es una regla especial. "Mira hacia adelante" y asegura que
#   los siguientes 3 caracteres NO SEAN "000". Es la forma más
#   eficiente de excluir el 000 del rango 001-999.
#
# \\d{3} (Clase y Cuantificador):
#   \d significa "cualquier dígito" (0-9).
#   {3} significa "exactamente 3 veces".
#   Junto con (?!000), valida el rango 001-999.
#
# - (Literal):
#   Busca el guion literal.
#
# [A-HJ-NP-Z]{2} (Clase Personalizada y Cuantificador):
#   [A-HJ-NP-Z] es una clase que define los caracteres permitidos:
#   "Cualquier letra mayúscula de la A a la H, O de la J a la N,
#   O de la P a la Z". Esto excluye 'I' y 'O'.
#   {2} exige "exactamente 2" de esos caracteres.
#
# $ (Ancla de fin):
#   Exige que la placa termine exactamente aquí. Evita coincidencias
#   parciales como "NY-M-123-AB-XYZ".
#

# ---
# --- EJERCICIO 3 DE 4: CONJUNTO DE PRUEBAS (8 CASOS) ---
# ---

# Creamos un vector de cadenas (placas) para probar nuestra regex
# También creamos un vector paralelo con el resultado que esperamos
# (TRUE si es válida, FALSE si es inválida).

placas_a_probar <- c(
  # --- 5 Casos Válidos (Esperado: TRUE) ---
  "NY-M-123-AB",  # Caso estándar
  "NY-F-007-XY",  # Con ceros a la izquierda
  "NY-G-999-ZZ",  # Caso de límites (número y letras máximas)
  "NY-M-500-HJ",  # Prueba letras H y J (lados de la I)
  "NY-F-101-NP",  # Prueba letras N y P (lados de la O)
  
  # --- 3 Casos Inválidos (Esperado: FALSE) ---
  "NY-X-123-AB",  # Tipo 'X' inválido
  "NY-M-000-CD",  # Número '000' inválido
  "NY-G-456-IO"   # Zona con 'I' y 'O' inválida
)

resultado_esperado <- c(
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  FALSE,
  FALSE,
  FALSE
)

# --- PASO 4: EJECUTAR LAS PRUEBAS ---

# Creamos un tibble (data frame) para mostrar los resultados
resultados_prueba <- tibble(
  Placa_Prueba = placas_a_probar,
  Resultado_Esperado = resultado_esperado,
  Validacion_Regex = str_detect(Placa_Prueba, regex_placa),
  # Creamos una columna que nos dice si la prueba fue exitosa
  Prueba_Exitosa = (Resultado_Esperado == Validacion_Regex)
)

# --- PASO 5: MOSTRAR LOS RESULTADOS EN CONSOLA ---

cat("--- PROYECTO 2: RESULTADOS DE PRUEBAS UNITARIAS ---\n\n")
print(resultados_prueba)
cat("\n")
# ---
# --- EJERCICIO 4 DE 4: VALIDACIÓN CASE-INSENSITIVE ---
# ---
#
#
# 1. ¿CÓMO HABILITAR LA VALIDACIÓN CASE-INSENSITIVE?
#
# En R, si estamos usando el paquete 'stringr' (parte de tidyverse),
# la forma más clara es envolver nuestra regex en la función 'regex()'
# y activar su argumento 'ignore_case = TRUE'.
# EJEMPLO: SOLO DEMOSTRACIÓN:
#
#   placa_minuscula <- "ny-m-123-ab"
#
#   # Esta validación normal (la que hicimos) da FALSE, lo cual es correcto
#   str_detect(placa_minuscula, regex_placa)
#
#   # Esta validación ignorando mayúsculas/minúsculas daría TRUE
#   str_detect(placa_minuscula, regex(regex_placa, ignore_case = TRUE))
#
#
# (Otra forma alternativa, usando "flags" de regex, sería empezar
#  el patrón con "(?i)": regex_placa_insensible <- "(?i)^NY-(M|F|G)..." )
#
#
# 2. ¿POR QUÉ NO DEBE PERMITIRSE EN ESTE CASO?
#
# Este se podría ver como un punto crítico de "Calidad de Datos" (Data Quality).
#
# * REGLA EXPLÍCITA: Las reglas del proyecto son estrictas. Definen
#     explícitamente que el prefijo es "NY" (mayúsculas) y la zona
#     son "dos letras MAYÚSCULAS".
#
# * LOS DATOS SUCIOS DEBEN SER RECHAZADOS: Las reglas nos dieron un
#     ejemplo inválido: "ny-m-245-zk (minúsculas)". Esto nos confirma
#     que las minúsculas son consideradas "datos sucios".
#
# * RIESGO DE VALIDACIÓN: Si activáramos 'ignore_case = TRUE', nuestro
#     script le daría "TRUE" (válido) a la placa "ny-m-245-zk", lo cual
#     es incorrecto. Estaríamos aceptando datos mal formateados como si
#     fueran buenos.
#
# * INTEGRIDAD DE DATOS (Data Integrity): El objetivo de una validación
#     tan estricta es forzar un "formato canónico" (único). Si permitimos
#     "NY-M-123-AB" y "ny-m-123-ab", en un análisis posterior (como un
#     conteo de taxis) R los trataría como dos placas distintas,
#     contaminando los resultados.
#
# En resumen: La validación debe ser estricta (case-sensitive) porque
# su propósito es RECHAZAR datos que no cumplan al 100% con el
# formato de datos limpio y estándar.
#
# --- FIN DEL EJERCICIO 4 ---
# --- FUENTES ---
# Fuente de datos: Escenario hipotético del proyecto.
# Reglas de Regex: Pistas técnicas proporcionadas en el proyecto.