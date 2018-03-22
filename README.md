#  Word Search App

## Organization
  
  ### Models
    #### JSONCodables 
    
    WordPuzzle
      Uses swift codable protocol to deserialize the data provided via the TapPuzzle API. Improperly 
      formatted datails filtered via a conditional initializer and methods internal to the WordPuzzle
      struct
    
    PuzzleStore 
      Acts as the Model object for the WordPuzzleViewController / Access point for validated 
      WordPuzzle structs. 
    
  ### Views

    Most of the UI in this app is generated programmatically with the help of .xib files. I tend to 
    take this approach for more complicated / animated views. Especially if there will be a transition 
    between vertical and horizontal orientations. 

    PuzzleContainerView 
      Acts as the background view for the application. All of the other modular views should rest inside 
      the container view. 
    
      Headerview
        Simple UI to display the next word and the language which you are to translate to. Designed to be 
        adjustable for any screen orientation by explicitly defining frames for vertical and horizontal 
        aspect ratios
    
      FlagView
        Simple view that displays country flag based on enum value
      
      WordGrid
        Word grid is designed so that it is possible to accomodate any sized puzzle between 3 - 8 characters on 
        a small screen. It could easily accomodate more on a large screen if desired.
      
        PuzzleLetterView
          This view is the main point of interaction for the user
    
   
   ### Controller
   
    WordPuzzleViewController
      This view controller handles the sizing of it's subviews as well as all of the logic for puzzle 
      presntation, touch handling and answer validation.
   
   
   ### Networking
   
    Any decodable can be called using this modularized API client. To do so, follow three steps: 
   
    1: Define the Endpoint in the Endpoint.swift document with links to all the base + path pairs your client will
       access
    2: Extend the model store (whichever class with be requesting from the API client) to conform to the APIClient
       protocol
    3: Create methods to fetch json objects when given specific endpoints
   
   
## Proposed Next Steps

    Hypothetical Priority list given more time:
    - 100% Unit Test coverage of business logic
    - Add a marker that  indicates user position during any give time to help them realize
      when on an invalid path
    - Add sounds for dragging / completion of puzzle.
    - Create UI To handle no internet state, logic to reattempt
    - Error Reporting / Analytics
    - Automatically generate puzzles given list of words to minimize data transfer / storage
    - Refine UI/UX, Full App cycle, Icon / Launch Screen / Main Screen 


 
