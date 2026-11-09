import 'geo.dart';
import 'personaje.dart';

const plazaPrincipal = Coordenada(21.15610, -100.93180);

// Datos de práctica del manual.
const personajes = <Personaje>[
  Personaje(
    id: 'hidalgo',
    nombre: 'Miguel Hidalgo',
    emoji: '🔔',
    bio: 'Cura de Dolores. Convocó al pueblo a levantarse en armas con el Grito de Dolores.',
    pregunta: Pregunta(
      '¿En qué año dio Hidalgo el Grito de Dolores?',
      ['1810', '1821', '1857', '1910'],
      0,
    ),
  ),
  Personaje(
    id: 'allende',
    nombre: 'Ignacio Allende',
    emoji: '⚔️',
    bio: 'Militar criollo y uno de los principales jefes del movimiento insurgente.',
    pregunta: Pregunta(
      '¿Con qué rango militar participó Ignacio Allende?',
      ['Almirante', 'Capitán', 'Cardenal', 'Virrey'],
      1,
    ),
  ),
  Personaje(
    id: 'josefa',
    nombre: 'Josefa Ortiz de Domínguez',
    emoji: '🗝️',
    bio: 'Participó en la conspiración de Querétaro y ayudó a avisar a los insurgentes.',
    pregunta: Pregunta(
      '¿Con qué apodo se conoce a Josefa Ortiz de Domínguez?',
      [
        'La Malinche',
        'La Güera',
        'La Corregidora',
        'La Adelita',
      ],
      2,
    ),
  ),
  Personaje(
    id: 'aldama',
    nombre: 'Juan Aldama',
    emoji: '🐎',
    bio: 'Capitán insurgente que llegó a Dolores con noticias urgentes sobre la conspiración.',
    pregunta: Pregunta(
      '¿Qué noticia llevó Juan Aldama a Hidalgo en Dolores?',
      [
        'Que la conspiración había sido descubierta',
        'Que había llegado el nuevo virrey',
        'Que la guerra había terminado',
        'Que se cancelaba la fiesta del pueblo',
      ],
      0,
    ),
  ),
  Personaje(
    id: 'abasolo',
    nombre: 'Mariano Abasolo',
    emoji: '🛡️',
    bio: 'Capitán insurgente nacido en Dolores, participó desde el inicio del movimiento.',
    pregunta: Pregunta(
      '¿En qué ciudad nació el capitán Mariano Abasolo?',
      ['Monterrey', 'Mérida', 'Oaxaca', 'Dolores Hidalgo'],
      3,
    ),
  ),
  Personaje(
    id: 'leona',
    nombre: 'Leona Vicario',
    emoji: '📰',
    bio: 'Apoyó a los insurgentes con dinero, mensajes e información, y es recordada como periodista.',
    pregunta: Pregunta(
      '¿Qué actividad destacó a Leona Vicario además de apoyar la insurgencia?',
      [
        'Periodista',
        'Marinera',
        'Cantante de ópera',
        'Arquitecta',
      ],
      0,
    ),
  ),
];