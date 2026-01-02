import '../models/word_association_models.dart';

/// Comprehensive word association data for the vocabulary game
/// Organized by category with increasing difficulty levels
class WordAssociationData {
  static const List<WordAssociation> allWords = [
    // ============================================
    // EMOTIONS - Positive
    // ============================================
    WordAssociation(
      id: 'happy_chain',
      baseWord: 'happy',
      baseDefinition: 'Feeling or showing pleasure or contentment',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'joyful',
          level: 1,
          definition: 'Full of joy; very happy',
        ),
        AssociatedWord(
          word: 'elated',
          level: 2,
          definition: 'Extremely happy and excited',
        ),
        AssociatedWord(
          word: 'ecstatic',
          level: 3,
          definition: 'Overwhelmingly happy; in a state of rapture',
        ),
      ],
      sentences: {
        'happy':
            'She felt happy after receiving the good news about her promotion.',
        'joyful':
            'The joyful children ran through the garden, laughing and playing.',
        'elated':
            'He was elated when he found out he had been accepted to his dream university.',
        'ecstatic':
            'The fans were ecstatic when their team won the championship.',
      },
    ),
    WordAssociation(
      id: 'excited_chain',
      baseWord: 'excited',
      baseDefinition: 'Very enthusiastic and eager',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'thrilled',
          level: 1,
          definition: 'Extremely pleased and excited',
        ),
        AssociatedWord(
          word: 'exhilarated',
          level: 2,
          definition: 'Very happy, animated, or elated',
        ),
        AssociatedWord(
          word: 'euphoric',
          level: 3,
          definition: 'Characterized by intense excitement and happiness',
        ),
      ],
      sentences: {
        'excited':
            'The children were excited about their upcoming trip to the amusement park.',
        'thrilled':
            'She was thrilled to meet her favorite author at the book signing.',
        'exhilarated':
            'After completing the marathon, he felt exhilarated despite his exhaustion.',
        'euphoric': 'The team was euphoric after breaking the world record.',
      },
    ),
    WordAssociation(
      id: 'calm_chain',
      baseWord: 'calm',
      baseDefinition: 'Not showing or feeling nervousness or strong emotions',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'peaceful',
          level: 1,
          definition: 'Free from disturbance; tranquil',
        ),
        AssociatedWord(
          word: 'serene',
          level: 2,
          definition: 'Calm, peaceful, and untroubled',
        ),
        AssociatedWord(
          word: 'tranquil',
          level: 3,
          definition: 'Free from disturbance or turmoil',
        ),
      ],
      sentences: {
        'calm': 'Despite the chaos around her, she remained calm and focused.',
        'peaceful':
            'The peaceful morning by the lake was exactly what she needed.',
        'serene': 'Her serene expression showed no sign of worry.',
        'tranquil': 'The tranquil garden was a perfect place for meditation.',
      },
    ),

    // ============================================
    // EMOTIONS - Negative
    // ============================================
    WordAssociation(
      id: 'sad_chain',
      baseWord: 'sad',
      baseDefinition: 'Feeling or showing sorrow; unhappy',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'sorrowful',
          level: 1,
          definition: 'Feeling or showing grief',
        ),
        AssociatedWord(
          word: 'miserable',
          level: 2,
          definition: 'Very unhappy or uncomfortable',
        ),
        AssociatedWord(
          word: 'devastated',
          level: 3,
          definition: 'Overwhelmed with shock or grief',
        ),
      ],
      sentences: {
        'sad': 'He felt sad when his best friend moved to another city.',
        'sorrowful': 'Her sorrowful eyes told the story of her loss.',
        'miserable':
            'The cold rain made everyone feel miserable during the outdoor event.',
        'devastated': 'The family was devastated by the unexpected news.',
      },
    ),
    WordAssociation(
      id: 'angry_chain',
      baseWord: 'angry',
      baseDefinition: 'Feeling or showing strong annoyance or displeasure',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'furious',
          level: 1,
          definition: 'Extremely angry',
        ),
        AssociatedWord(
          word: 'enraged',
          level: 2,
          definition: 'Very angry; furious',
        ),
        AssociatedWord(word: 'livid', level: 3, definition: 'Furiously angry'),
      ],
      sentences: {
        'angry': 'She was angry when she discovered the broken vase.',
        'furious': 'He was furious after learning about the betrayal.',
        'enraged': 'The crowd became enraged at the unfair decision.',
        'livid': 'Her boss was livid when the project deadline was missed.',
      },
    ),
    WordAssociation(
      id: 'scared_chain',
      baseWord: 'scared',
      baseDefinition: 'Fearful; frightened',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'frightened',
          level: 1,
          definition: 'Afraid or anxious',
        ),
        AssociatedWord(
          word: 'terrified',
          level: 2,
          definition: 'Extremely frightened',
        ),
        AssociatedWord(
          word: 'petrified',
          level: 3,
          definition: 'So frightened that one is unable to move',
        ),
      ],
      sentences: {
        'scared': 'The child was scared of the dark and needed a night light.',
        'frightened': 'The frightened deer ran into the forest.',
        'terrified': 'She was terrified during the thunderstorm.',
        'petrified': 'He stood petrified when he saw the snake on the path.',
      },
    ),
    WordAssociation(
      id: 'tired_chain',
      baseWord: 'tired',
      baseDefinition: 'In need of sleep or rest; weary',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'weary',
          level: 1,
          definition: 'Feeling or showing tiredness',
        ),
        AssociatedWord(
          word: 'exhausted',
          level: 2,
          definition: 'Completely drained of energy',
        ),
        AssociatedWord(
          word: 'drained',
          level: 3,
          definition: 'Deprived of physical or emotional strength',
        ),
      ],
      sentences: {
        'tired': 'After the long day, she felt tired and ready for bed.',
        'weary': 'The weary travelers finally reached their destination.',
        'exhausted': 'He was exhausted after running the marathon.',
        'drained':
            'The emotional conversation left her feeling completely drained.',
      },
    ),

    // ============================================
    // SIZE & QUANTITY
    // ============================================
    WordAssociation(
      id: 'big_chain',
      baseWord: 'big',
      baseDefinition: 'Of considerable size or extent',
      partOfSpeech: 'adjective',
      category: 'description',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'large',
          level: 1,
          definition: 'Of considerable size',
        ),
        AssociatedWord(word: 'huge', level: 2, definition: 'Extremely large'),
        AssociatedWord(
          word: 'enormous',
          level: 3,
          definition: 'Very large in size or quantity',
        ),
      ],
      sentences: {
        'big': 'They live in a big house on the corner of the street.',
        'large': 'The large crowd gathered to watch the parade.',
        'huge': 'A huge wave crashed against the shore.',
        'enormous':
            'The museum had an enormous collection of ancient artifacts.',
      },
    ),
    WordAssociation(
      id: 'small_chain',
      baseWord: 'small',
      baseDefinition: 'Of a size that is less than normal or usual',
      partOfSpeech: 'adjective',
      category: 'description',
      difficulty: 1,
      associations: [
        AssociatedWord(word: 'tiny', level: 1, definition: 'Very small'),
        AssociatedWord(
          word: 'miniature',
          level: 2,
          definition: 'Much smaller than normal',
        ),
        AssociatedWord(
          word: 'microscopic',
          level: 3,
          definition: 'So small as to be visible only with a microscope',
        ),
      ],
      sentences: {
        'small': 'The small café was cozy and welcoming.',
        'tiny': 'A tiny kitten was hiding under the sofa.',
        'miniature': 'She collected miniature dollhouse furniture.',
        'microscopic':
            'Bacteria are microscopic organisms that cannot be seen with the naked eye.',
      },
    ),
    WordAssociation(
      id: 'many_chain',
      baseWord: 'many',
      baseDefinition: 'A large number of',
      partOfSpeech: 'adjective',
      category: 'quantity',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'numerous',
          level: 1,
          definition: 'Great in number; many',
        ),
        AssociatedWord(
          word: 'countless',
          level: 2,
          definition: 'Too many to be counted',
        ),
        AssociatedWord(
          word: 'innumerable',
          level: 3,
          definition: 'Too many to be counted; countless',
        ),
      ],
      sentences: {
        'many': 'Many students attended the lecture on climate change.',
        'numerous': 'She received numerous awards for her research.',
        'countless': 'He spent countless hours perfecting his craft.',
        'innumerable': 'The night sky was filled with innumerable stars.',
      },
    ),

    // ============================================
    // SPEED & MOVEMENT
    // ============================================
    WordAssociation(
      id: 'fast_chain',
      baseWord: 'fast',
      baseDefinition: 'Moving or capable of moving at high speed',
      partOfSpeech: 'adjective',
      category: 'movement',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'quick',
          level: 1,
          definition: 'Moving fast or doing something in a short time',
        ),
        AssociatedWord(
          word: 'rapid',
          level: 2,
          definition: 'Happening in a short time or at great speed',
        ),
        AssociatedWord(
          word: 'lightning-fast',
          level: 3,
          definition: 'Extremely fast, like lightning',
        ),
      ],
      sentences: {
        'fast': 'The fast car zoomed past the other vehicles.',
        'quick': 'She made a quick decision and caught the last train.',
        'rapid': 'The rapid development of technology has changed our lives.',
        'lightning-fast':
            'His lightning-fast reflexes saved him from the accident.',
      },
    ),
    WordAssociation(
      id: 'slow_chain',
      baseWord: 'slow',
      baseDefinition: 'Moving or operating at a low speed',
      partOfSpeech: 'adjective',
      category: 'movement',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'gradual',
          level: 1,
          definition: 'Taking place slowly over time',
        ),
        AssociatedWord(
          word: 'sluggish',
          level: 2,
          definition: 'Slow-moving or inactive',
        ),
        AssociatedWord(
          word: 'lethargic',
          level: 3,
          definition: 'Affected by lethargy; sluggish and apathetic',
        ),
      ],
      sentences: {
        'slow': 'The slow traffic made him late for work.',
        'gradual':
            'There was a gradual improvement in his health over the months.',
        'sluggish': 'The economy remained sluggish throughout the quarter.',
        'lethargic': 'The heat made everyone feel lethargic and unmotivated.',
      },
    ),

    // ============================================
    // INTELLIGENCE & KNOWLEDGE
    // ============================================
    WordAssociation(
      id: 'smart_chain',
      baseWord: 'smart',
      baseDefinition: 'Having or showing quick intelligence',
      partOfSpeech: 'adjective',
      category: 'intelligence',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'clever',
          level: 1,
          definition: 'Quick to understand and learn',
        ),
        AssociatedWord(
          word: 'brilliant',
          level: 2,
          definition: 'Exceptionally clever or talented',
        ),
        AssociatedWord(
          word: 'genius',
          level: 3,
          definition: 'Exceptionally intelligent or creative',
        ),
      ],
      sentences: {
        'smart': 'She is a smart student who always finishes her work early.',
        'clever': 'His clever solution impressed everyone in the meeting.',
        'brilliant': 'The scientist made a brilliant discovery.',
        'genius': 'Mozart was considered a musical genius from childhood.',
      },
    ),
    WordAssociation(
      id: 'confused_chain',
      baseWord: 'confused',
      baseDefinition: 'Unable to think clearly; bewildered',
      partOfSpeech: 'adjective',
      category: 'mental_state',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'puzzled',
          level: 1,
          definition: 'Unable to understand; perplexed',
        ),
        AssociatedWord(
          word: 'bewildered',
          level: 2,
          definition: 'Perplexed and confused',
        ),
        AssociatedWord(
          word: 'baffled',
          level: 3,
          definition: 'Completely unable to understand',
        ),
      ],
      sentences: {
        'confused': 'The tourist looked confused trying to read the map.',
        'puzzled': 'She was puzzled by the strange message.',
        'bewildered': 'The new employee seemed bewildered on his first day.',
        'baffled': 'Scientists are baffled by the mysterious phenomenon.',
      },
    ),

    // ============================================
    // ACTIONS - Speaking
    // ============================================
    WordAssociation(
      id: 'say_chain',
      baseWord: 'say',
      baseDefinition: 'To utter words to convey information',
      partOfSpeech: 'verb',
      category: 'communication',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'state',
          level: 1,
          definition: 'Express something definitely or clearly',
        ),
        AssociatedWord(
          word: 'declare',
          level: 2,
          definition: 'Say something in an emphatic manner',
        ),
        AssociatedWord(
          word: 'proclaim',
          level: 3,
          definition: 'Announce officially or publicly',
        ),
      ],
      sentences: {
        'say': 'What did she say about the meeting?',
        'state': 'Please state your name and address for the record.',
        'declare': 'The president will declare a national emergency.',
        'proclaim':
            'The town crier would proclaim important news to the citizens.',
      },
    ),
    WordAssociation(
      id: 'ask_chain',
      baseWord: 'ask',
      baseDefinition: 'To put a question to',
      partOfSpeech: 'verb',
      category: 'communication',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'inquire',
          level: 1,
          definition: 'Ask for information',
        ),
        AssociatedWord(
          word: 'question',
          level: 2,
          definition: 'Ask questions of someone',
        ),
        AssociatedWord(
          word: 'interrogate',
          level: 3,
          definition: 'Ask questions aggressively or formally',
        ),
      ],
      sentences: {
        'ask': 'Don\'t be afraid to ask for help when you need it.',
        'inquire': 'She called to inquire about the job opening.',
        'question': 'The detective began to question the witness.',
        'interrogate': 'The police will interrogate the suspect tomorrow.',
      },
    ),
    WordAssociation(
      id: 'talk_chain',
      baseWord: 'talk',
      baseDefinition: 'To speak in order to give information or express ideas',
      partOfSpeech: 'verb',
      category: 'communication',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'discuss',
          level: 1,
          definition: 'Talk about something with another person',
        ),
        AssociatedWord(
          word: 'converse',
          level: 2,
          definition: 'Engage in conversation',
        ),
        AssociatedWord(
          word: 'deliberate',
          level: 3,
          definition: 'Engage in long and careful consideration',
        ),
      ],
      sentences: {
        'talk': 'Let\'s talk about your plans for the weekend.',
        'discuss': 'We need to discuss the budget for next year.',
        'converse': 'They would converse for hours about philosophy.',
        'deliberate': 'The jury will deliberate before reaching a verdict.',
      },
    ),

    // ============================================
    // ACTIONS - Looking
    // ============================================
    WordAssociation(
      id: 'look_chain',
      baseWord: 'look',
      baseDefinition: 'To direct one\'s gaze toward someone or something',
      partOfSpeech: 'verb',
      category: 'perception',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'gaze',
          level: 1,
          definition: 'Look steadily and intently',
        ),
        AssociatedWord(
          word: 'stare',
          level: 2,
          definition: 'Look fixedly at something',
        ),
        AssociatedWord(
          word: 'scrutinize',
          level: 3,
          definition: 'Examine or inspect closely',
        ),
      ],
      sentences: {
        'look': 'Look at the beautiful sunset over the mountains.',
        'gaze': 'She would gaze out the window, lost in thought.',
        'stare': 'It\'s rude to stare at people.',
        'scrutinize':
            'The editor will scrutinize every detail of the manuscript.',
      },
    ),
    WordAssociation(
      id: 'see_chain',
      baseWord: 'see',
      baseDefinition: 'To perceive with the eyes',
      partOfSpeech: 'verb',
      category: 'perception',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'observe',
          level: 1,
          definition: 'Notice or perceive something',
        ),
        AssociatedWord(
          word: 'witness',
          level: 2,
          definition: 'See an event happen',
        ),
        AssociatedWord(
          word: 'behold',
          level: 3,
          definition: 'See or observe something remarkable',
        ),
      ],
      sentences: {
        'see': 'Can you see the ship on the horizon?',
        'observe': 'Scientists observe animal behavior in the wild.',
        'witness': 'They were lucky to witness the rare eclipse.',
        'behold': 'Behold the magnificent architecture of the ancient temple!',
      },
    ),

    // ============================================
    // ACTIONS - Walking/Moving
    // ============================================
    WordAssociation(
      id: 'walk_chain',
      baseWord: 'walk',
      baseDefinition:
          'To move at a regular pace by lifting and setting down each foot',
      partOfSpeech: 'verb',
      category: 'movement',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'stroll',
          level: 1,
          definition: 'Walk in a leisurely way',
        ),
        AssociatedWord(
          word: 'march',
          level: 2,
          definition: 'Walk with regular steps',
        ),
        AssociatedWord(
          word: 'stride',
          level: 3,
          definition: 'Walk with long, decisive steps',
        ),
      ],
      sentences: {
        'walk': 'Let\'s walk to the park this afternoon.',
        'stroll': 'They strolled along the beach at sunset.',
        'march': 'The soldiers will march in the parade tomorrow.',
        'stride': 'He strode confidently into the boardroom.',
      },
    ),
    WordAssociation(
      id: 'run_chain',
      baseWord: 'run',
      baseDefinition: 'To move at a speed faster than a walk',
      partOfSpeech: 'verb',
      category: 'movement',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'jog',
          level: 1,
          definition: 'Run at a steady, gentle pace',
        ),
        AssociatedWord(
          word: 'sprint',
          level: 2,
          definition: 'Run at full speed for a short distance',
        ),
        AssociatedWord(
          word: 'dash',
          level: 3,
          definition: 'Run or move very quickly',
        ),
      ],
      sentences: {
        'run': 'I run every morning to stay healthy.',
        'jog': 'She likes to jog through the park before breakfast.',
        'sprint': 'The athletes will sprint to the finish line.',
        'dash': 'He had to dash to catch the last bus.',
      },
    ),

    // ============================================
    // QUALITY - Good/Bad
    // ============================================
    WordAssociation(
      id: 'good_chain',
      baseWord: 'good',
      baseDefinition: 'Of a high quality or standard',
      partOfSpeech: 'adjective',
      category: 'quality',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'excellent',
          level: 1,
          definition: 'Extremely good',
        ),
        AssociatedWord(
          word: 'outstanding',
          level: 2,
          definition: 'Exceptionally good',
        ),
        AssociatedWord(
          word: 'superb',
          level: 3,
          definition: 'Of the highest quality',
        ),
      ],
      sentences: {
        'good': 'That was a good presentation you gave today.',
        'excellent': 'Her test scores were excellent this semester.',
        'outstanding':
            'The chef received outstanding reviews for her new restaurant.',
        'superb': 'The orchestra gave a superb performance last night.',
      },
    ),
    WordAssociation(
      id: 'bad_chain',
      baseWord: 'bad',
      baseDefinition: 'Of poor quality or a low standard',
      partOfSpeech: 'adjective',
      category: 'quality',
      difficulty: 1,
      associations: [
        AssociatedWord(word: 'terrible', level: 1, definition: 'Extremely bad'),
        AssociatedWord(
          word: 'dreadful',
          level: 2,
          definition: 'Causing great suffering or fear',
        ),
        AssociatedWord(
          word: 'atrocious',
          level: 3,
          definition: 'Of a very poor quality',
        ),
      ],
      sentences: {
        'bad': 'The weather has been bad all week.',
        'terrible': 'The movie received terrible reviews from critics.',
        'dreadful': 'The traffic conditions were dreadful during rush hour.',
        'atrocious': 'The team\'s performance was atrocious in the finals.',
      },
    ),

    // ============================================
    // BEAUTY & APPEARANCE
    // ============================================
    WordAssociation(
      id: 'beautiful_chain',
      baseWord: 'beautiful',
      baseDefinition: 'Pleasing to the senses or mind aesthetically',
      partOfSpeech: 'adjective',
      category: 'appearance',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'gorgeous',
          level: 1,
          definition: 'Very beautiful or attractive',
        ),
        AssociatedWord(
          word: 'stunning',
          level: 2,
          definition: 'Extremely impressive or attractive',
        ),
        AssociatedWord(
          word: 'breathtaking',
          level: 3,
          definition: 'Astonishing or awe-inspiring in quality',
        ),
      ],
      sentences: {
        'beautiful': 'The garden looked beautiful in spring.',
        'gorgeous': 'She wore a gorgeous dress to the gala.',
        'stunning': 'The view from the mountaintop was stunning.',
        'breathtaking': 'The aurora borealis was absolutely breathtaking.',
      },
    ),
    WordAssociation(
      id: 'ugly_chain',
      baseWord: 'ugly',
      baseDefinition: 'Unpleasant or repulsive in appearance',
      partOfSpeech: 'adjective',
      category: 'appearance',
      difficulty: 2,
      associations: [
        AssociatedWord(word: 'hideous', level: 1, definition: 'Extremely ugly'),
        AssociatedWord(
          word: 'grotesque',
          level: 2,
          definition: 'Comically or repulsively ugly',
        ),
        AssociatedWord(
          word: 'monstrous',
          level: 3,
          definition: 'Having the appearance of a monster',
        ),
      ],
      sentences: {
        'ugly': 'The abandoned building looked ugly and run-down.',
        'hideous': 'The villain wore a hideous mask.',
        'grotesque': 'The gargoyles had grotesque faces carved in stone.',
        'monstrous': 'The storm created monstrous waves on the ocean.',
      },
    ),

    // ============================================
    // TEMPERATURE
    // ============================================
    WordAssociation(
      id: 'hot_chain',
      baseWord: 'hot',
      baseDefinition: 'Having a high temperature',
      partOfSpeech: 'adjective',
      category: 'sensation',
      difficulty: 1,
      associations: [
        AssociatedWord(word: 'warm', level: 1, definition: 'Moderately hot'),
        AssociatedWord(
          word: 'scorching',
          level: 2,
          definition: 'Very hot and dry',
        ),
        AssociatedWord(
          word: 'sweltering',
          level: 3,
          definition: 'Uncomfortably hot',
        ),
      ],
      sentences: {
        'hot': 'The coffee is still too hot to drink.',
        'warm': 'The warm sunshine felt pleasant on her face.',
        'scorching': 'The scorching desert sun made travel difficult.',
        'sweltering': 'They worked outside in the sweltering summer heat.',
      },
    ),
    WordAssociation(
      id: 'cold_chain',
      baseWord: 'cold',
      baseDefinition: 'Having a low temperature',
      partOfSpeech: 'adjective',
      category: 'sensation',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'chilly',
          level: 1,
          definition: 'Unpleasantly cold',
        ),
        AssociatedWord(word: 'freezing', level: 2, definition: 'Very cold'),
        AssociatedWord(word: 'frigid', level: 3, definition: 'Extremely cold'),
      ],
      sentences: {
        'cold': 'The water was too cold for swimming.',
        'chilly': 'It was a chilly autumn morning.',
        'freezing': 'The freezing temperatures caused the pipes to burst.',
        'frigid': 'Arctic explorers must prepare for frigid conditions.',
      },
    ),

    // ============================================
    // IMPORTANCE & VALUE
    // ============================================
    WordAssociation(
      id: 'important_chain',
      baseWord: 'important',
      baseDefinition: 'Of great significance or value',
      partOfSpeech: 'adjective',
      category: 'significance',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'significant',
          level: 1,
          definition: 'Sufficiently great or important',
        ),
        AssociatedWord(
          word: 'crucial',
          level: 2,
          definition: 'Of great importance',
        ),
        AssociatedWord(
          word: 'vital',
          level: 3,
          definition: 'Absolutely necessary or essential',
        ),
      ],
      sentences: {
        'important': 'Education is important for personal growth.',
        'significant': 'There has been a significant increase in sales.',
        'crucial': 'This is a crucial moment in the negotiations.',
        'vital': 'Clean water is vital for human survival.',
      },
    ),

    // ============================================
    // DIFFICULTY
    // ============================================
    WordAssociation(
      id: 'easy_chain',
      baseWord: 'easy',
      baseDefinition: 'Achieved without great effort',
      partOfSpeech: 'adjective',
      category: 'difficulty',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'simple',
          level: 1,
          definition: 'Easily done or understood',
        ),
        AssociatedWord(
          word: 'effortless',
          level: 2,
          definition: 'Requiring no physical or mental effort',
        ),
        AssociatedWord(
          word: 'elementary',
          level: 3,
          definition: 'Relating to the basic elements of a subject',
        ),
      ],
      sentences: {
        'easy': 'The first level of the game was easy to complete.',
        'simple': 'She gave simple instructions that everyone understood.',
        'effortless': 'The professional made the dance moves look effortless.',
        'elementary':
            'This is elementary mathematics taught in primary school.',
      },
    ),
    WordAssociation(
      id: 'hard_chain',
      baseWord: 'hard',
      baseDefinition: 'Requiring great effort or endurance',
      partOfSpeech: 'adjective',
      category: 'difficulty',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'difficult',
          level: 1,
          definition: 'Needing much effort to accomplish',
        ),
        AssociatedWord(
          word: 'challenging',
          level: 2,
          definition: 'Testing one\'s abilities',
        ),
        AssociatedWord(
          word: 'arduous',
          level: 3,
          definition: 'Involving much hard work',
        ),
      ],
      sentences: {
        'hard': 'Learning a new language is hard but rewarding.',
        'difficult': 'The exam was more difficult than expected.',
        'challenging': 'The challenging puzzle took hours to solve.',
        'arduous':
            'The arduous journey through the mountains tested their limits.',
      },
    ),

    // ============================================
    // CERTAINTY
    // ============================================
    WordAssociation(
      id: 'sure_chain',
      baseWord: 'sure',
      baseDefinition: 'Confident in what one thinks or knows',
      partOfSpeech: 'adjective',
      category: 'certainty',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'certain',
          level: 1,
          definition: 'Known for sure; established beyond doubt',
        ),
        AssociatedWord(
          word: 'confident',
          level: 2,
          definition: 'Feeling certain about something',
        ),
        AssociatedWord(
          word: 'convinced',
          level: 3,
          definition: 'Completely certain',
        ),
      ],
      sentences: {
        'sure': 'I\'m sure we\'ve met before somewhere.',
        'certain': 'She was certain that she had locked the door.',
        'confident': 'He was confident in his ability to succeed.',
        'convinced': 'The jury was convinced of the defendant\'s innocence.',
      },
    ),

    // ============================================
    // ACTIONS - Eating
    // ============================================
    WordAssociation(
      id: 'eat_chain',
      baseWord: 'eat',
      baseDefinition: 'To put food into the mouth and chew and swallow it',
      partOfSpeech: 'verb',
      category: 'actions',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'consume',
          level: 1,
          definition: 'Eat or drink; use up',
        ),
        AssociatedWord(
          word: 'devour',
          level: 2,
          definition: 'Eat food quickly and eagerly',
        ),
        AssociatedWord(
          word: 'gobble',
          level: 3,
          definition: 'Eat something hurriedly and noisily',
        ),
      ],
      sentences: {
        'eat': 'Let\'s eat dinner at seven o\'clock.',
        'consume':
            'Athletes consume large amounts of protein for muscle recovery.',
        'devour': 'The hungry children devoured the pizza in minutes.',
        'gobble': 'Don\'t gobble your food; eat slowly and enjoy it.',
      },
    ),

    // ============================================
    // ACTIONS - Thinking
    // ============================================
    WordAssociation(
      id: 'think_chain',
      baseWord: 'think',
      baseDefinition: 'To have a particular opinion or belief',
      partOfSpeech: 'verb',
      category: 'cognition',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'consider',
          level: 1,
          definition: 'Think carefully about something',
        ),
        AssociatedWord(
          word: 'ponder',
          level: 2,
          definition: 'Think about something carefully',
        ),
        AssociatedWord(
          word: 'contemplate',
          level: 3,
          definition: 'Look at thoughtfully for a long time',
        ),
      ],
      sentences: {
        'think': 'What do you think about the new policy?',
        'consider': 'Please consider all options before making a decision.',
        'ponder': 'She would often ponder the meaning of life.',
        'contemplate': 'He sat quietly to contemplate his future.',
      },
    ),
    WordAssociation(
      id: 'understand_chain',
      baseWord: 'understand',
      baseDefinition: 'To perceive the intended meaning of',
      partOfSpeech: 'verb',
      category: 'cognition',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'comprehend',
          level: 1,
          definition: 'Grasp mentally; understand',
        ),
        AssociatedWord(
          word: 'grasp',
          level: 2,
          definition: 'Seize and hold firmly; understand',
        ),
        AssociatedWord(
          word: 'fathom',
          level: 3,
          definition: 'Understand after much thought',
        ),
      ],
      sentences: {
        'understand': 'I don\'t understand this math problem.',
        'comprehend':
            'It took time to comprehend the complexity of the situation.',
        'grasp': 'She quickly grasped the main concepts of the lecture.',
        'fathom': 'He couldn\'t fathom why she made that decision.',
      },
    ),

    // ============================================
    // ACTIONS - Creating
    // ============================================
    WordAssociation(
      id: 'make_chain',
      baseWord: 'make',
      baseDefinition: 'To form something by putting parts together',
      partOfSpeech: 'verb',
      category: 'creation',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'create',
          level: 1,
          definition: 'Bring something into existence',
        ),
        AssociatedWord(
          word: 'construct',
          level: 2,
          definition: 'Build or make something',
        ),
        AssociatedWord(
          word: 'fabricate',
          level: 3,
          definition: 'Construct or manufacture',
        ),
      ],
      sentences: {
        'make': 'Can you make dinner tonight?',
        'create': 'Artists create beautiful works of art.',
        'construct': 'Workers will construct a new bridge over the river.',
        'fabricate': 'The factory fabricates high-quality steel components.',
      },
    ),

    // ============================================
    // PERSONALITY TRAITS
    // ============================================
    WordAssociation(
      id: 'nice_chain',
      baseWord: 'nice',
      baseDefinition: 'Pleasant; agreeable; satisfactory',
      partOfSpeech: 'adjective',
      category: 'personality',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'kind',
          level: 1,
          definition: 'Considerate and helpful',
        ),
        AssociatedWord(
          word: 'generous',
          level: 2,
          definition: 'Willing to give more than necessary',
        ),
        AssociatedWord(
          word: 'benevolent',
          level: 3,
          definition: 'Well-meaning and kindly',
        ),
      ],
      sentences: {
        'nice': 'What a nice gesture to bring flowers!',
        'kind': 'It was kind of you to help the elderly woman.',
        'generous': 'His generous donation helped build the new library.',
        'benevolent': 'The benevolent millionaire funded several charities.',
      },
    ),
    WordAssociation(
      id: 'mean_chain',
      baseWord: 'mean',
      baseDefinition: 'Unkind, spiteful, or unfair',
      partOfSpeech: 'adjective',
      category: 'personality',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'cruel',
          level: 1,
          definition: 'Willfully causing pain or suffering',
        ),
        AssociatedWord(
          word: 'malicious',
          level: 2,
          definition: 'Intending to do harm',
        ),
        AssociatedWord(
          word: 'vicious',
          level: 3,
          definition: 'Deliberately cruel or violent',
        ),
      ],
      sentences: {
        'mean': 'It\'s mean to make fun of others.',
        'cruel': 'Abandoning pets is a cruel act.',
        'malicious': 'The malicious rumor spread quickly through the school.',
        'vicious': 'The vicious attack left the victim hospitalized.',
      },
    ),
    WordAssociation(
      id: 'brave_chain',
      baseWord: 'brave',
      baseDefinition: 'Ready to face and endure danger or pain',
      partOfSpeech: 'adjective',
      category: 'personality',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'courageous',
          level: 1,
          definition: 'Not deterred by danger or pain',
        ),
        AssociatedWord(
          word: 'fearless',
          level: 2,
          definition: 'Showing no fear',
        ),
        AssociatedWord(
          word: 'valiant',
          level: 3,
          definition: 'Possessing or showing courage',
        ),
      ],
      sentences: {
        'brave':
            'The brave firefighter rescued the child from the burning building.',
        'courageous': 'Her courageous decision changed the course of history.',
        'fearless': 'The fearless explorer ventured into uncharted territory.',
        'valiant': 'The knights made a valiant effort to defend the castle.',
      },
    ),

    // ============================================
    // WEALTH & POVERTY
    // ============================================
    WordAssociation(
      id: 'rich_chain',
      baseWord: 'rich',
      baseDefinition: 'Having a great deal of money or assets',
      partOfSpeech: 'adjective',
      category: 'wealth',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'wealthy',
          level: 1,
          definition: 'Having a great deal of money',
        ),
        AssociatedWord(
          word: 'affluent',
          level: 2,
          definition: 'Having a great deal of money; wealthy',
        ),
        AssociatedWord(
          word: 'opulent',
          level: 3,
          definition: 'Ostentatiously rich and luxurious',
        ),
      ],
      sentences: {
        'rich': 'The rich businessman donated to charity.',
        'wealthy': 'They come from a wealthy family.',
        'affluent': 'She grew up in an affluent neighborhood.',
        'opulent': 'The hotel lobby was decorated in an opulent style.',
      },
    ),
    WordAssociation(
      id: 'poor_chain',
      baseWord: 'poor',
      baseDefinition:
          'Lacking sufficient money to live at a comfortable standard',
      partOfSpeech: 'adjective',
      category: 'wealth',
      difficulty: 2,
      associations: [
        AssociatedWord(word: 'impoverished', level: 1, definition: 'Made poor'),
        AssociatedWord(
          word: 'destitute',
          level: 2,
          definition: 'Without basic necessities',
        ),
        AssociatedWord(
          word: 'penniless',
          level: 3,
          definition: 'Having no money',
        ),
      ],
      sentences: {
        'poor': 'The poor family struggled to make ends meet.',
        'impoverished': 'The war left the nation impoverished.',
        'destitute': 'The charity helps destitute families in the community.',
        'penniless': 'He arrived in the city penniless but full of hope.',
      },
    ),

    // ============================================
    // LIGHT & DARKNESS
    // ============================================
    WordAssociation(
      id: 'bright_chain',
      baseWord: 'bright',
      baseDefinition: 'Giving out or reflecting much light',
      partOfSpeech: 'adjective',
      category: 'light',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'luminous',
          level: 1,
          definition: 'Full of or shedding light',
        ),
        AssociatedWord(
          word: 'radiant',
          level: 2,
          definition: 'Shining or glowing brightly',
        ),
        AssociatedWord(
          word: 'dazzling',
          level: 3,
          definition: 'Extremely bright, especially blindingly so',
        ),
      ],
      sentences: {
        'bright': 'The bright sun made it difficult to see.',
        'luminous': 'The luminous stars filled the night sky.',
        'radiant': 'Her radiant smile lit up the room.',
        'dazzling': 'The dazzling display of fireworks amazed everyone.',
      },
    ),
    WordAssociation(
      id: 'dark_chain',
      baseWord: 'dark',
      baseDefinition: 'With little or no light',
      partOfSpeech: 'adjective',
      category: 'light',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'dim',
          level: 1,
          definition: 'Not bright or clear',
        ),
        AssociatedWord(word: 'murky', level: 2, definition: 'Dark and gloomy'),
        AssociatedWord(
          word: 'pitch-black',
          level: 3,
          definition: 'Completely dark',
        ),
      ],
      sentences: {
        'dark': 'The room was dark until she opened the curtains.',
        'dim': 'The dim lighting created a romantic atmosphere.',
        'murky': 'The murky water made it impossible to see the bottom.',
        'pitch-black': 'The cave was pitch-black without a flashlight.',
      },
    ),

    // ============================================
    // EMOTIONS - Advanced Positive
    // ============================================
    WordAssociation(
      id: 'proud_chain',
      baseWord: 'proud',
      baseDefinition: 'Feeling deep pleasure from achievements',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'dignified',
          level: 1,
          definition: 'Having a serious manner worthy of respect',
        ),
        AssociatedWord(
          word: 'honorable',
          level: 2,
          definition: 'Bringing or deserving honor',
        ),
        AssociatedWord(
          word: 'illustrious',
          level: 3,
          definition: 'Well known and esteemed',
        ),
      ],
      sentences: {
        'proud': 'She felt proud of her academic achievements.',
        'dignified': 'He maintained a dignified composure during the crisis.',
        'honorable': 'An honorable person always keeps their word.',
        'illustrious': 'The university has an illustrious history of research.',
      },
    ),
    WordAssociation(
      id: 'grateful_chain',
      baseWord: 'grateful',
      baseDefinition: 'Feeling or showing thanks',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'thankful',
          level: 1,
          definition: 'Pleased and relieved',
        ),
        AssociatedWord(
          word: 'appreciative',
          level: 2,
          definition: 'Feeling or showing gratitude',
        ),
        AssociatedWord(
          word: 'indebted',
          level: 3,
          definition: 'Owing gratitude for a service or favor',
        ),
      ],
      sentences: {
        'grateful': 'I am deeply grateful for your assistance.',
        'thankful': 'We are thankful to have such supportive friends.',
        'appreciative': 'The audience was appreciative of the performance.',
        'indebted': 'I feel indebted to my mentor for guidance.',
      },
    ),
    WordAssociation(
      id: 'hopeful_chain',
      baseWord: 'hopeful',
      baseDefinition: 'Feeling or inspiring optimism',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'optimistic',
          level: 1,
          definition: 'Hopeful and confident about the future',
        ),
        AssociatedWord(
          word: 'sanguine',
          level: 2,
          definition: 'Cheerfully optimistic',
        ),
        AssociatedWord(
          word: 'buoyant',
          level: 3,
          definition: 'Cheerful and optimistic',
        ),
      ],
      sentences: {
        'hopeful': 'She remained hopeful despite the setbacks.',
        'optimistic': 'He has an optimistic outlook on life.',
        'sanguine': 'Despite challenges, she maintained a sanguine attitude.',
        'buoyant': 'The team\'s buoyant spirits lifted everyone\'s mood.',
      },
    ),

    // ============================================
    // EMOTIONS - Advanced Negative
    // ============================================
    WordAssociation(
      id: 'anxious_chain',
      baseWord: 'anxious',
      baseDefinition: 'Experiencing worry or unease',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'apprehensive',
          level: 1,
          definition: 'Anxious about the future',
        ),
        AssociatedWord(
          word: 'distressed',
          level: 2,
          definition: 'Suffering from extreme anxiety',
        ),
        AssociatedWord(
          word: 'anguished',
          level: 3,
          definition: 'Experiencing severe mental suffering',
        ),
      ],
      sentences: {
        'anxious': 'She felt anxious before the job interview.',
        'apprehensive': 'He was apprehensive about the upcoming surgery.',
        'distressed': 'The distressed family awaited news of the rescue.',
        'anguished': 'Her anguished cries echoed through the hospital.',
      },
    ),
    WordAssociation(
      id: 'jealous_chain',
      baseWord: 'jealous',
      baseDefinition: 'Feeling resentment against someone',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'envious',
          level: 1,
          definition: 'Feeling discontent at others\' advantages',
        ),
        AssociatedWord(
          word: 'covetous',
          level: 2,
          definition: 'Having a strong desire for possessions',
        ),
        AssociatedWord(
          word: 'resentful',
          level: 3,
          definition: 'Feeling bitterness at unfair treatment',
        ),
      ],
      sentences: {
        'jealous': 'He became jealous when she talked to others.',
        'envious': 'She was envious of her colleague\'s promotion.',
        'covetous': 'His covetous eyes lingered on the luxury car.',
        'resentful': 'He grew resentful of his brother\'s success.',
      },
    ),
    WordAssociation(
      id: 'ashamed_chain',
      baseWord: 'ashamed',
      baseDefinition: 'Embarrassed or guilty because of actions',
      partOfSpeech: 'adjective',
      category: 'emotions',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'embarrassed',
          level: 1,
          definition: 'Feeling awkward and self-conscious',
        ),
        AssociatedWord(
          word: 'humiliated',
          level: 2,
          definition: 'Made to feel ashamed and foolish',
        ),
        AssociatedWord(
          word: 'mortified',
          level: 3,
          definition: 'Extremely embarrassed',
        ),
      ],
      sentences: {
        'ashamed': 'He was ashamed of his rude behavior.',
        'embarrassed': 'She felt embarrassed after tripping in public.',
        'humiliated': 'The athlete felt humiliated by the crushing defeat.',
        'mortified': 'I was mortified when I called her by the wrong name.',
      },
    ),

    // ============================================
    // COGNITIVE - Memory & Knowledge
    // ============================================
    WordAssociation(
      id: 'remember_chain',
      baseWord: 'remember',
      baseDefinition: 'To have in or be able to bring to mind',
      partOfSpeech: 'verb',
      category: 'cognition',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'recall',
          level: 1,
          definition: 'Bring a fact back into one\'s mind',
        ),
        AssociatedWord(
          word: 'recollect',
          level: 2,
          definition: 'Remember something',
        ),
        AssociatedWord(
          word: 'reminisce',
          level: 3,
          definition: 'Indulge in enjoyable recollection of past events',
        ),
      ],
      sentences: {
        'remember': 'I remember meeting you at the conference.',
        'recall': 'Can you recall where you left your keys?',
        'recollect': 'I cannot recollect the exact details of the event.',
        'reminisce': 'They loved to reminisce about their college days.',
      },
    ),
    WordAssociation(
      id: 'forget_chain',
      baseWord: 'forget',
      baseDefinition: 'Fail to remember',
      partOfSpeech: 'verb',
      category: 'cognition',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'overlook',
          level: 1,
          definition: 'Fail to notice or consider',
        ),
        AssociatedWord(
          word: 'neglect',
          level: 2,
          definition: 'Fail to care for properly',
        ),
        AssociatedWord(
          word: 'disregard',
          level: 3,
          definition: 'Pay no attention to; ignore',
        ),
      ],
      sentences: {
        'forget': 'Don\'t forget to lock the door when you leave.',
        'overlook': 'We must not overlook any important details.',
        'neglect': 'He tends to neglect his health when busy.',
        'disregard': 'She chose to disregard the warning signs.',
      },
    ),
    WordAssociation(
      id: 'learn_chain',
      baseWord: 'learn',
      baseDefinition: 'Gain knowledge or skill through study',
      partOfSpeech: 'verb',
      category: 'cognition',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'acquire',
          level: 1,
          definition: 'Learn or develop a skill or quality',
        ),
        AssociatedWord(
          word: 'assimilate',
          level: 2,
          definition: 'Absorb and integrate information',
        ),
        AssociatedWord(
          word: 'internalize',
          level: 3,
          definition: 'Make attitudes or behavior part of one\'s nature',
        ),
      ],
      sentences: {
        'learn': 'Children learn languages quickly.',
        'acquire': 'She worked hard to acquire new programming skills.',
        'assimilate': 'It takes time to assimilate complex information.',
        'internalize': 'Students should internalize these core principles.',
      },
    ),

    // ============================================
    // COMMUNICATION - Advanced
    // ============================================
    WordAssociation(
      id: 'explain_chain',
      baseWord: 'explain',
      baseDefinition: 'Make an idea clear to someone',
      partOfSpeech: 'verb',
      category: 'communication',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'clarify',
          level: 1,
          definition: 'Make a statement less confused',
        ),
        AssociatedWord(
          word: 'elucidate',
          level: 2,
          definition: 'Make something clear; explain',
        ),
        AssociatedWord(
          word: 'expound',
          level: 3,
          definition: 'Present and explain in detail',
        ),
      ],
      sentences: {
        'explain': 'Can you explain how this machine works?',
        'clarify': 'Let me clarify what I meant by that statement.',
        'elucidate': 'The professor elucidated the complex theory.',
        'expound': 'She expounded her views on climate change.',
      },
    ),
    WordAssociation(
      id: 'argue_chain',
      baseWord: 'argue',
      baseDefinition: 'Exchange diverging views heatedly',
      partOfSpeech: 'verb',
      category: 'communication',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'debate',
          level: 1,
          definition: 'Argue about a subject formally',
        ),
        AssociatedWord(
          word: 'dispute',
          level: 2,
          definition: 'Argue or disagree strongly',
        ),
        AssociatedWord(
          word: 'contend',
          level: 3,
          definition: 'Assert something as a position in argument',
        ),
      ],
      sentences: {
        'argue': 'They often argue about politics.',
        'debate': 'The candidates will debate the key issues tonight.',
        'dispute': 'The two countries dispute ownership of the island.',
        'contend': 'Scientists contend that more research is needed.',
      },
    ),
    WordAssociation(
      id: 'suggest_chain',
      baseWord: 'suggest',
      baseDefinition: 'Put forward for consideration',
      partOfSpeech: 'verb',
      category: 'communication',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'propose',
          level: 1,
          definition: 'Put forward an idea for consideration',
        ),
        AssociatedWord(
          word: 'recommend',
          level: 2,
          definition: 'Put forward with approval as suitable',
        ),
        AssociatedWord(
          word: 'advocate',
          level: 3,
          definition: 'Publicly recommend or support',
        ),
      ],
      sentences: {
        'suggest': 'I suggest we take a different approach.',
        'propose': 'They propose building a new community center.',
        'recommend': 'Doctors recommend regular exercise.',
        'advocate': 'Many experts advocate for renewable energy.',
      },
    ),
    WordAssociation(
      id: 'criticize_chain',
      baseWord: 'criticize',
      baseDefinition: 'Indicate faults of someone or something',
      partOfSpeech: 'verb',
      category: 'communication',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'condemn',
          level: 1,
          definition: 'Express complete disapproval',
        ),
        AssociatedWord(
          word: 'denounce',
          level: 2,
          definition: 'Publicly declare to be wrong',
        ),
        AssociatedWord(
          word: 'disparage',
          level: 3,
          definition: 'Regard or represent as being of little worth',
        ),
      ],
      sentences: {
        'criticize': 'It\'s easy to criticize but hard to create.',
        'condemn': 'World leaders condemn the act of terrorism.',
        'denounce': 'She publicly denounced the unfair practices.',
        'disparage': 'He tends to disparage others\' accomplishments.',
      },
    ),

    // ============================================
    // ACTIONS - Physical Movement Advanced
    // ============================================
    WordAssociation(
      id: 'jump_chain',
      baseWord: 'jump',
      baseDefinition: 'Push oneself off the ground using legs',
      partOfSpeech: 'verb',
      category: 'movement',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'leap',
          level: 1,
          definition: 'Jump a long way with force',
        ),
        AssociatedWord(
          word: 'vault',
          level: 2,
          definition: 'Jump over using hands or a pole',
        ),
        AssociatedWord(
          word: 'hurdle',
          level: 3,
          definition: 'Jump over an obstacle while running',
        ),
      ],
      sentences: {
        'jump': 'The cat can jump onto the highest shelf.',
        'leap': 'The athlete made a spectacular leap over the bar.',
        'vault': 'She managed to vault over the fence.',
        'hurdle': 'Runners must hurdle ten barriers during the race.',
      },
    ),
    WordAssociation(
      id: 'climb_chain',
      baseWord: 'climb',
      baseDefinition: 'Go or come up a slope or stairs',
      partOfSpeech: 'verb',
      category: 'movement',
      difficulty: 1,
      associations: [
        AssociatedWord(word: 'ascend', level: 1, definition: 'Go up or climb'),
        AssociatedWord(
          word: 'scale',
          level: 2,
          definition: 'Climb up or over something high',
        ),
        AssociatedWord(
          word: 'surmount',
          level: 3,
          definition: 'Overcome a difficulty or obstacle',
        ),
      ],
      sentences: {
        'climb': 'We decided to climb the mountain this weekend.',
        'ascend': 'The hikers began to ascend the steep trail.',
        'scale': 'Climbers scale the rock face using special equipment.',
        'surmount': 'She managed to surmount all the obstacles.',
      },
    ),
    WordAssociation(
      id: 'fall_chain',
      baseWord: 'fall',
      baseDefinition: 'Move downward typically rapidly and freely',
      partOfSpeech: 'verb',
      category: 'movement',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'tumble',
          level: 1,
          definition: 'Fall suddenly and helplessly',
        ),
        AssociatedWord(
          word: 'plunge',
          level: 2,
          definition: 'Jump or dive quickly',
        ),
        AssociatedWord(
          word: 'plummet',
          level: 3,
          definition: 'Fall or drop straight down rapidly',
        ),
      ],
      sentences: {
        'fall': 'Be careful not to fall on the wet floor.',
        'tumble': 'The child tumbled down the grassy hill.',
        'plunge': 'The diver will plunge into the cold water.',
        'plummet': 'Stock prices plummeted after the announcement.',
      },
    ),

    // ============================================
    // SIZE & QUANTITY - Advanced
    // ============================================
    WordAssociation(
      id: 'huge_chain',
      baseWord: 'huge',
      baseDefinition: 'Extremely large; enormous',
      partOfSpeech: 'adjective',
      category: 'description',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'massive',
          level: 1,
          definition: 'Large and heavy or solid',
        ),
        AssociatedWord(
          word: 'colossal',
          level: 2,
          definition: 'Extremely large',
        ),
        AssociatedWord(
          word: 'gargantuan',
          level: 3,
          definition: 'Enormous in size',
        ),
      ],
      sentences: {
        'huge': 'The huge elephant walked slowly across the savanna.',
        'massive': 'A massive boulder blocked the entrance to the cave.',
        'colossal': 'The colossal statue towered over the city.',
        'gargantuan': 'The gargantuan feast had enough food for a hundred.',
      },
    ),
    WordAssociation(
      id: 'tiny_chain',
      baseWord: 'tiny',
      baseDefinition: 'Very small',
      partOfSpeech: 'adjective',
      category: 'description',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'minuscule',
          level: 1,
          definition: 'Extremely small; tiny',
        ),
        AssociatedWord(
          word: 'microscopic',
          level: 2,
          definition: 'So small as to be visible only with a microscope',
        ),
        AssociatedWord(
          word: 'infinitesimal',
          level: 3,
          definition: 'Extremely small; immeasurably minute',
        ),
      ],
      sentences: {
        'tiny': 'The tiny kitten fit in the palm of her hand.',
        'minuscule': 'The font size was minuscule and hard to read.',
        'microscopic': 'Bacteria are microscopic organisms.',
        'infinitesimal': 'The chances of winning are infinitesimal.',
      },
    ),
    WordAssociation(
      id: 'empty_chain',
      baseWord: 'empty',
      baseDefinition: 'Containing nothing; not filled',
      partOfSpeech: 'adjective',
      category: 'quantity',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'vacant',
          level: 1,
          definition: 'Not occupied; empty',
        ),
        AssociatedWord(
          word: 'barren',
          level: 2,
          definition: 'Too poor to produce vegetation',
        ),
        AssociatedWord(
          word: 'desolate',
          level: 3,
          definition: 'Deserted and empty',
        ),
      ],
      sentences: {
        'empty': 'The refrigerator was completely empty.',
        'vacant': 'The vacant apartment has been listed for months.',
        'barren': 'The barren landscape stretched for miles.',
        'desolate': 'The desolate town had been abandoned for years.',
      },
    ),
    WordAssociation(
      id: 'full_chain',
      baseWord: 'full',
      baseDefinition: 'Containing as much as possible',
      partOfSpeech: 'adjective',
      category: 'quantity',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'packed',
          level: 1,
          definition: 'Very crowded or full',
        ),
        AssociatedWord(
          word: 'brimming',
          level: 2,
          definition: 'Filled to the point of overflowing',
        ),
        AssociatedWord(
          word: 'replete',
          level: 3,
          definition: 'Filled or well-supplied with something',
        ),
      ],
      sentences: {
        'full': 'The theater was full on opening night.',
        'packed': 'The stadium was packed with enthusiastic fans.',
        'brimming': 'Her eyes were brimming with tears of joy.',
        'replete': 'The museum is replete with historical artifacts.',
      },
    ),

    // ============================================
    // TIME & SPEED - Advanced
    // ============================================
    WordAssociation(
      id: 'quick_chain',
      baseWord: 'quick',
      baseDefinition: 'Moving fast or done in a short time',
      partOfSpeech: 'adjective',
      category: 'speed',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'swift',
          level: 1,
          definition: 'Happening quickly or promptly',
        ),
        AssociatedWord(
          word: 'nimble',
          level: 2,
          definition: 'Quick and light in movement',
        ),
        AssociatedWord(
          word: 'expeditious',
          level: 3,
          definition: 'Done with speed and efficiency',
        ),
      ],
      sentences: {
        'quick': 'She made a quick decision to accept the offer.',
        'swift': 'The government took swift action to address the crisis.',
        'nimble': 'The nimble dancer moved gracefully across the stage.',
        'expeditious': 'We need an expeditious resolution to this matter.',
      },
    ),
    WordAssociation(
      id: 'old_chain',
      baseWord: 'old',
      baseDefinition: 'Having lived for many years',
      partOfSpeech: 'adjective',
      category: 'time',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'ancient',
          level: 1,
          definition: 'Belonging to the very distant past',
        ),
        AssociatedWord(
          word: 'archaic',
          level: 2,
          definition: 'Very old or old-fashioned',
        ),
        AssociatedWord(
          word: 'antiquated',
          level: 3,
          definition: 'Old-fashioned or outdated',
        ),
      ],
      sentences: {
        'old': 'The old building has historical significance.',
        'ancient': 'The ancient ruins date back thousands of years.',
        'archaic': 'The archaic laws need to be modernized.',
        'antiquated': 'Their antiquated equipment slowed down production.',
      },
    ),
    WordAssociation(
      id: 'new_chain',
      baseWord: 'new',
      baseDefinition: 'Not existing before; recently made',
      partOfSpeech: 'adjective',
      category: 'time',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'modern',
          level: 1,
          definition: 'Relating to the present or recent times',
        ),
        AssociatedWord(
          word: 'contemporary',
          level: 2,
          definition: 'Living or occurring at the same time',
        ),
        AssociatedWord(
          word: 'innovative',
          level: 3,
          definition: 'Introducing new ideas or methods',
        ),
      ],
      sentences: {
        'new': 'She bought a new car last week.',
        'modern': 'The modern building features cutting-edge design.',
        'contemporary': 'Contemporary art reflects current social issues.',
        'innovative': 'Their innovative approach revolutionized the industry.',
      },
    ),

    // ============================================
    // QUALITY & VALUE - Advanced
    // ============================================
    WordAssociation(
      id: 'perfect_chain',
      baseWord: 'perfect',
      baseDefinition: 'Having all the required qualities',
      partOfSpeech: 'adjective',
      category: 'quality',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'flawless',
          level: 1,
          definition: 'Without any imperfections',
        ),
        AssociatedWord(
          word: 'impeccable',
          level: 2,
          definition: 'Without faults or errors',
        ),
        AssociatedWord(
          word: 'exemplary',
          level: 3,
          definition: 'Serving as a desirable model',
        ),
      ],
      sentences: {
        'perfect': 'The weather was perfect for a picnic.',
        'flawless': 'Her flawless performance earned a standing ovation.',
        'impeccable': 'He has impeccable taste in fashion.',
        'exemplary': 'Her exemplary conduct earned her a promotion.',
      },
    ),
    WordAssociation(
      id: 'terrible_chain',
      baseWord: 'terrible',
      baseDefinition: 'Extremely bad or serious',
      partOfSpeech: 'adjective',
      category: 'quality',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'dreadful',
          level: 1,
          definition: 'Causing great suffering or fear',
        ),
        AssociatedWord(
          word: 'atrocious',
          level: 2,
          definition: 'Of very poor quality; horrifying',
        ),
        AssociatedWord(
          word: 'abysmal',
          level: 3,
          definition: 'Extremely bad; appalling',
        ),
      ],
      sentences: {
        'terrible': 'The terrible storm caused widespread damage.',
        'dreadful': 'The news of the accident was dreadful.',
        'atrocious': 'The service at the restaurant was atrocious.',
        'abysmal': 'The team\'s abysmal performance disappointed fans.',
      },
    ),
    WordAssociation(
      id: 'useful_chain',
      baseWord: 'useful',
      baseDefinition: 'Able to be used for a practical purpose',
      partOfSpeech: 'adjective',
      category: 'quality',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'practical',
          level: 1,
          definition: 'Likely to succeed or be effective',
        ),
        AssociatedWord(
          word: 'beneficial',
          level: 2,
          definition: 'Resulting in good; favorable',
        ),
        AssociatedWord(
          word: 'advantageous',
          level: 3,
          definition: 'Involving favorable circumstances',
        ),
      ],
      sentences: {
        'useful': 'This tool is very useful for home repairs.',
        'practical': 'She gave practical advice for saving money.',
        'beneficial': 'Exercise is beneficial for mental health.',
        'advantageous': 'The location proved advantageous for business.',
      },
    ),

    // ============================================
    // PERSONALITY - Advanced Traits
    // ============================================
    WordAssociation(
      id: 'clever_chain',
      baseWord: 'clever',
      baseDefinition: 'Quick to understand and learn',
      partOfSpeech: 'adjective',
      category: 'personality',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'ingenious',
          level: 1,
          definition: 'Clever, original, and inventive',
        ),
        AssociatedWord(
          word: 'shrewd',
          level: 2,
          definition: 'Having sharp powers of judgment',
        ),
        AssociatedWord(
          word: 'astute',
          level: 3,
          definition: 'Having an ability to assess situations accurately',
        ),
      ],
      sentences: {
        'clever': 'The clever student solved the puzzle quickly.',
        'ingenious': 'He came up with an ingenious solution to the problem.',
        'shrewd': 'A shrewd businesswoman, she negotiated a great deal.',
        'astute': 'The astute detective noticed the crucial clue.',
      },
    ),
    WordAssociation(
      id: 'lazy_chain',
      baseWord: 'lazy',
      baseDefinition: 'Unwilling to work or use energy',
      partOfSpeech: 'adjective',
      category: 'personality',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'idle',
          level: 1,
          definition: 'Not working or active',
        ),
        AssociatedWord(
          word: 'lethargic',
          level: 2,
          definition: 'Sluggish and apathetic',
        ),
        AssociatedWord(
          word: 'indolent',
          level: 3,
          definition: 'Wanting to avoid activity or exertion',
        ),
      ],
      sentences: {
        'lazy': 'Don\'t be lazy; finish your homework.',
        'idle': 'The machines stood idle during the strike.',
        'lethargic': 'The heat made everyone feel lethargic.',
        'indolent': 'His indolent nature prevented career advancement.',
      },
    ),
    WordAssociation(
      id: 'honest_chain',
      baseWord: 'honest',
      baseDefinition: 'Free of deceit; truthful',
      partOfSpeech: 'adjective',
      category: 'personality',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'sincere',
          level: 1,
          definition: 'Free from pretense; genuine',
        ),
        AssociatedWord(
          word: 'candid',
          level: 2,
          definition: 'Truthful and straightforward',
        ),
        AssociatedWord(
          word: 'forthright',
          level: 3,
          definition: 'Direct and outspoken',
        ),
      ],
      sentences: {
        'honest': 'An honest person admits their mistakes.',
        'sincere': 'Her sincere apology was accepted graciously.',
        'candid': 'I appreciate your candid feedback.',
        'forthright': 'The forthright manager addressed the issues directly.',
      },
    ),
    WordAssociation(
      id: 'stubborn_chain',
      baseWord: 'stubborn',
      baseDefinition: 'Having a firm refusal to change',
      partOfSpeech: 'adjective',
      category: 'personality',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'obstinate',
          level: 1,
          definition: 'Stubbornly refusing to change opinion',
        ),
        AssociatedWord(
          word: 'tenacious',
          level: 2,
          definition: 'Keeping a firm hold on something',
        ),
        AssociatedWord(
          word: 'intransigent',
          level: 3,
          definition: 'Unwilling to change views or compromise',
        ),
      ],
      sentences: {
        'stubborn': 'The stubborn child refused to eat vegetables.',
        'obstinate': 'His obstinate refusal delayed the negotiations.',
        'tenacious': 'Her tenacious effort finally paid off.',
        'intransigent': 'The intransigent stance hindered progress.',
      },
    ),

    // ============================================
    // ACTIONS - Work & Achievement
    // ============================================
    WordAssociation(
      id: 'succeed_chain',
      baseWord: 'succeed',
      baseDefinition: 'Achieve the desired aim or result',
      partOfSpeech: 'verb',
      category: 'achievement',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'prosper',
          level: 1,
          definition: 'Succeed in material terms; flourish',
        ),
        AssociatedWord(
          word: 'thrive',
          level: 2,
          definition: 'Grow or develop well',
        ),
        AssociatedWord(
          word: 'flourish',
          level: 3,
          definition: 'Develop rapidly and successfully',
        ),
      ],
      sentences: {
        'succeed': 'With hard work, you will succeed.',
        'prosper': 'The business continued to prosper despite challenges.',
        'thrive': 'Children thrive in supportive environments.',
        'flourish': 'The arts flourished during the Renaissance.',
      },
    ),
    WordAssociation(
      id: 'fail_chain',
      baseWord: 'fail',
      baseDefinition: 'Be unsuccessful in achieving a goal',
      partOfSpeech: 'verb',
      category: 'achievement',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'falter',
          level: 1,
          definition: 'Start to lose strength or momentum',
        ),
        AssociatedWord(
          word: 'flounder',
          level: 2,
          definition: 'Struggle or stagger clumsily',
        ),
        AssociatedWord(
          word: 'founder',
          level: 3,
          definition: 'Fail or break down completely',
        ),
      ],
      sentences: {
        'fail': 'Don\'t be afraid to fail; it\'s how we learn.',
        'falter': 'Her voice began to falter as she spoke.',
        'flounder': 'Without guidance, the project began to flounder.',
        'founder': 'The peace talks foundered on the issue of territory.',
      },
    ),
    WordAssociation(
      id: 'help_chain',
      baseWord: 'help',
      baseDefinition: 'Make it easier for someone to do something',
      partOfSpeech: 'verb',
      category: 'actions',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'assist',
          level: 1,
          definition: 'Help someone by sharing work',
        ),
        AssociatedWord(
          word: 'facilitate',
          level: 2,
          definition: 'Make an action easier',
        ),
        AssociatedWord(
          word: 'expedite',
          level: 3,
          definition: 'Make an action happen sooner',
        ),
      ],
      sentences: {
        'help': 'Can you help me carry these boxes?',
        'assist': 'Staff members are ready to assist customers.',
        'facilitate': 'Technology facilitates communication.',
        'expedite': 'We need to expedite the approval process.',
      },
    ),
    WordAssociation(
      id: 'stop_chain',
      baseWord: 'stop',
      baseDefinition: 'Cease to happen or exist',
      partOfSpeech: 'verb',
      category: 'actions',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'cease',
          level: 1,
          definition: 'Come or bring to an end',
        ),
        AssociatedWord(
          word: 'halt',
          level: 2,
          definition: 'Bring to an abrupt stop',
        ),
        AssociatedWord(
          word: 'discontinue',
          level: 3,
          definition: 'Stop doing or providing something',
        ),
      ],
      sentences: {
        'stop': 'Please stop making so much noise.',
        'cease': 'The fighting ceased after the treaty was signed.',
        'halt': 'Construction came to a halt due to weather.',
        'discontinue': 'The company will discontinue this product line.',
      },
    ),
    WordAssociation(
      id: 'change_chain',
      baseWord: 'change',
      baseDefinition: 'Make or become different',
      partOfSpeech: 'verb',
      category: 'actions',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'alter',
          level: 1,
          definition: 'Change in character or composition',
        ),
        AssociatedWord(
          word: 'modify',
          level: 2,
          definition: 'Make partial changes to something',
        ),
        AssociatedWord(
          word: 'transform',
          level: 3,
          definition: 'Make a thorough change in form or appearance',
        ),
      ],
      sentences: {
        'change': 'People can change if they want to.',
        'alter': 'The tailor will alter the suit to fit you.',
        'modify': 'We need to modify our approach.',
        'transform': 'Technology has transformed the way we work.',
      },
    ),

    // ============================================
    // FEELINGS - Physical Sensations
    // ============================================
    WordAssociation(
      id: 'hungry_chain',
      baseWord: 'hungry',
      baseDefinition: 'Feeling or displaying need for food',
      partOfSpeech: 'adjective',
      category: 'sensation',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'famished',
          level: 1,
          definition: 'Extremely hungry',
        ),
        AssociatedWord(
          word: 'ravenous',
          level: 2,
          definition: 'Extremely hungry; voracious',
        ),
        AssociatedWord(
          word: 'voracious',
          level: 3,
          definition: 'Wanting great quantities of food',
        ),
      ],
      sentences: {
        'hungry': 'I\'m getting hungry; let\'s have lunch.',
        'famished': 'After the hike, we were all famished.',
        'ravenous': 'The ravenous wolf hunted for its next meal.',
        'voracious': 'He has a voracious appetite for learning.',
      },
    ),
    WordAssociation(
      id: 'thirsty_chain',
      baseWord: 'thirsty',
      baseDefinition: 'Feeling a need to drink',
      partOfSpeech: 'adjective',
      category: 'sensation',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'parched',
          level: 1,
          definition: 'Extremely thirsty',
        ),
        AssociatedWord(
          word: 'dehydrated',
          level: 2,
          definition: 'Having lost large amounts of water',
        ),
        AssociatedWord(
          word: 'desiccated',
          level: 3,
          definition: 'Lacking moisture; dried out',
        ),
      ],
      sentences: {
        'thirsty': 'Playing sports makes me very thirsty.',
        'parched': 'The desert sun left travelers parched.',
        'dehydrated': 'Athletes can become dehydrated in hot weather.',
        'desiccated': 'The desiccated plants needed watering urgently.',
      },
    ),
    WordAssociation(
      id: 'sick_chain',
      baseWord: 'sick',
      baseDefinition: 'Affected by illness',
      partOfSpeech: 'adjective',
      category: 'sensation',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'ill',
          level: 1,
          definition: 'Not in full health; sick',
        ),
        AssociatedWord(word: 'ailing', level: 2, definition: 'In poor health'),
        AssociatedWord(
          word: 'afflicted',
          level: 3,
          definition: 'Suffering from an illness or condition',
        ),
      ],
      sentences: {
        'sick': 'She called in sick to work today.',
        'ill': 'The patient has been ill for several weeks.',
        'ailing': 'He visited his ailing grandmother in hospital.',
        'afflicted': 'The region is afflicted by drought.',
      },
    ),

    // ============================================
    // NATURE & WEATHER
    // ============================================
    WordAssociation(
      id: 'wet_chain',
      baseWord: 'wet',
      baseDefinition: 'Covered or saturated with water',
      partOfSpeech: 'adjective',
      category: 'weather',
      difficulty: 1,
      associations: [
        AssociatedWord(word: 'damp', level: 1, definition: 'Slightly wet'),
        AssociatedWord(
          word: 'soggy',
          level: 2,
          definition: 'Very wet and soft',
        ),
        AssociatedWord(
          word: 'saturated',
          level: 3,
          definition: 'Thoroughly soaked with water',
        ),
      ],
      sentences: {
        'wet': 'Don\'t sit on the wet grass.',
        'damp': 'The basement was cold and damp.',
        'soggy': 'The soggy cereal was unappetizing.',
        'saturated': 'The soil was saturated after the heavy rain.',
      },
    ),
    WordAssociation(
      id: 'dry_chain',
      baseWord: 'dry',
      baseDefinition: 'Free from moisture or liquid',
      partOfSpeech: 'adjective',
      category: 'weather',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'arid',
          level: 1,
          definition: 'Having little or no rain',
        ),
        AssociatedWord(
          word: 'parched',
          level: 2,
          definition: 'Dried out with heat',
        ),
        AssociatedWord(
          word: 'drought-stricken',
          level: 3,
          definition: 'Affected by lack of rain over time',
        ),
      ],
      sentences: {
        'dry': 'The towels were dry after hanging in the sun.',
        'arid': 'The arid climate supports little vegetation.',
        'parched': 'The parched earth cracked under the sun.',
        'drought-stricken': 'Aid was sent to drought-stricken regions.',
      },
    ),
    WordAssociation(
      id: 'windy_chain',
      baseWord: 'windy',
      baseDefinition: 'Marked by strong wind',
      partOfSpeech: 'adjective',
      category: 'weather',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'breezy',
          level: 1,
          definition: 'Pleasantly windy',
        ),
        AssociatedWord(
          word: 'gusty',
          level: 2,
          definition: 'Characterized by sudden rushes of wind',
        ),
        AssociatedWord(
          word: 'tempestuous',
          level: 3,
          definition: 'Characterized by strong turbulent winds',
        ),
      ],
      sentences: {
        'windy': 'It\'s too windy to fly a kite safely.',
        'breezy': 'The breezy weather made the picnic enjoyable.',
        'gusty': 'Gusty winds made driving conditions hazardous.',
        'tempestuous': 'The tempestuous seas delayed the voyage.',
      },
    ),

    // ============================================
    // RELATIONSHIPS & SOCIAL
    // ============================================
    WordAssociation(
      id: 'friendly_chain',
      baseWord: 'friendly',
      baseDefinition: 'Kind and pleasant',
      partOfSpeech: 'adjective',
      category: 'social',
      difficulty: 1,
      associations: [
        AssociatedWord(
          word: 'amiable',
          level: 1,
          definition: 'Having a friendly and pleasant manner',
        ),
        AssociatedWord(
          word: 'cordial',
          level: 2,
          definition: 'Warm and friendly',
        ),
        AssociatedWord(
          word: 'affable',
          level: 3,
          definition: 'Friendly and easy to talk to',
        ),
      ],
      sentences: {
        'friendly': 'The staff at the hotel were very friendly.',
        'amiable': 'Her amiable personality made her popular.',
        'cordial': 'They maintained a cordial relationship.',
        'affable': 'The affable host made everyone feel welcome.',
      },
    ),
    WordAssociation(
      id: 'unfriendly_chain',
      baseWord: 'unfriendly',
      baseDefinition: 'Not friendly',
      partOfSpeech: 'adjective',
      category: 'social',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'hostile',
          level: 1,
          definition: 'Unfriendly; antagonistic',
        ),
        AssociatedWord(
          word: 'aloof',
          level: 2,
          definition: 'Not friendly or forthcoming; cool',
        ),
        AssociatedWord(
          word: 'antagonistic',
          level: 3,
          definition: 'Showing or feeling active opposition',
        ),
      ],
      sentences: {
        'unfriendly': 'The unfriendly clerk barely acknowledged us.',
        'hostile': 'They faced a hostile reception from locals.',
        'aloof': 'He seemed aloof and unapproachable.',
        'antagonistic': 'The antagonistic tone of the debate was troubling.',
      },
    ),
    WordAssociation(
      id: 'famous_chain',
      baseWord: 'famous',
      baseDefinition: 'Known about by many people',
      partOfSpeech: 'adjective',
      category: 'social',
      difficulty: 2,
      associations: [
        AssociatedWord(
          word: 'renowned',
          level: 1,
          definition: 'Known or talked about by many people',
        ),
        AssociatedWord(
          word: 'celebrated',
          level: 2,
          definition: 'Greatly admired; renowned',
        ),
        AssociatedWord(
          word: 'illustrious',
          level: 3,
          definition: 'Well known and esteemed',
        ),
      ],
      sentences: {
        'famous': 'Paris is famous for the Eiffel Tower.',
        'renowned': 'She is a renowned expert in her field.',
        'celebrated': 'The celebrated author won many awards.',
        'illustrious': 'He had an illustrious career in science.',
      },
    ),
  ];

  /// Get words by category
  static List<WordAssociation> getByCategory(String category) {
    return allWords.where((w) => w.category == category).toList();
  }

  /// Get words by difficulty
  static List<WordAssociation> getByDifficulty(int difficulty) {
    return allWords.where((w) => w.difficulty == difficulty).toList();
  }

  /// Get random words for daily challenge
  static List<WordAssociation> getDailyWords(int count) {
    final shuffled = List<WordAssociation>.from(allWords)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Get all unique categories
  static List<String> get categories {
    return allWords.map((w) => w.category).toSet().toList()..sort();
  }
}
