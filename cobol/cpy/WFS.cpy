      *================================================================*
      * WFS.cpy                                                        *
      *================================================================*   
       
       01  :FNAME:-FILE-STATUS PIC XX.
        88 :FNAME:-FILE-OK VALUE '00'.
        88 :FNAME:-FILE-EOF VALUE '10'.

       01  :FNAME:-FILE-STATE PIC X VALUE 'C'.
        88 :FNAME:-FILE-IS-OPEN VALUE 'O'.
        88 :FNAME:-FILE-IS-CLOSED VALUE 'C'.
        
       01  :FNAME:-FILE-EMPTY PIC X VALUE 'Y'.
        88 :FNAME:-FILE-EMPTY-Y VALUE 'Y'.
        88 :FNAME:-FILE-EMPTY-N VALUE 'N'.

       01  :FNAME:-FILE-NEVER-OPEN PIC X VALUE 'O'.
        88 :FNAME:-FILE-OPENED VALUE 'O'.
        88 :FNAME:-FILE-NEVER-OPENED VALUE 'N'.
