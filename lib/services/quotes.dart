const List<String> motivationalQuotes = [
  'El único modo de hacer un gran trabajo es amar lo que haces.',
  'No cuentes los días, haz que los días cuenten.',
  'El éxito es la suma de pequeños esfuerzos repetidos día tras día.',
  'La disciplina es el puente entre metas y logros.',
  'No tienes que ser grande para empezar, pero tienes que empezar para ser grande.',
  'Cada día es una nueva oportunidad para cambiar tu vida.',
  'La constancia vence lo que la dicha no alcanza.',
  'Un pequeño paso hoy es mejor que un gran plan mañana.',
  'Tu única competencia eres tú mismo de ayer.',
  'Las cosas buenas llegan a quienes no dejan de intentarlo.',
  'El cambio empieza con una decisión, no con una condición perfecta.',
  'Confía en el proceso, los resultados llegan con el tiempo.',
  'No se trata de tener tiempo, se trata de hacer tiempo.',
  'Cree que puedes y ya estás a medio camino.',
  'La motivación te hace empezar, el hábito te hace continuar.',
  'Cada logro comienza con la decisión de intentarlo.',
  'Sé más fuerte que tu excusa más fuerte.',
  'El progreso, no la perfección, es lo que importa.',
  'Hoy es un buen día para ser un poco mejor que ayer.',
  'La versión de ti que quieres ser empieza por las decisiones de hoy.',
];

String quoteOfTheDay() {
  final dayOfYear = DateTime.now()
      .difference(DateTime(DateTime.now().year, 1, 1))
      .inDays;
  return motivationalQuotes[dayOfYear % motivationalQuotes.length];
}
