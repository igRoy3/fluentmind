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
