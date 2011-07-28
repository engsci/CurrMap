require(["ace/ace","ace/theme-clouds","ace/keyboard/hash_handler","ace/split"], function() {
  
  require.ready(function() {
    
    var container = document.getElementById("editor");
    var theme = require("ace/theme/clouds");
    var Split = require("ace/split").Split;
    var split = new Split(container, theme, 1);
  
     
    split.on("focus", function(e) {
        editor = e;
    });
    split.setSplits(2);
    var editors = [split.getEditor(0),split.getEditor(1)];
    var editor = editors[0];
    editor.focus();
    
    // set styles
    for(e in editors) {
      editors[e].setSelectionStyle("text");
      editors[e].renderer.setHScrollBarAlwaysVisible(false);
      editors[e].renderer.setShowGutter(false);
      editors[e].renderer.setShowPrintMargin(false);
    }
    
    var editor1width = 100;
    editors[0].container.style.width = editor1width + "px";
    editors[1].container.style.left = editor1width + "px";
    editors[0].resize();
    
    // custom keys
    
    /*
    var HashHandler = require("ace/keyboard/hash_handler").HashHandler;
    var keybindings = new HashHandler({
      "_indent": "Command-]",
      "_outdent": "Command-["
    });
    split.setKeyboardHandler(keybindings);
    */ 
        
    // custom actions
    
    var canon = require("pilot/canon");
        
    function bindKey(win, mac) {
      return {
        win: win,
        mac: mac,
        sender: "editor"
      };
    }
    
    function jumpRight() {
      editors[1].moveCursorTo(editors[0].$getSelectedRows().first,0);
      editors[1].focus();
    }
    
    function jumpLeft() {
      editors[0].moveCursorTo(editors[1].$getSelectedRows().first,999); //TODO: don't use 999
      editors[0].focus();
    }
    
    function syncCursor() {
      active = (editor == editors[1]) ? 1 : 0;
      times = editors[active].getCursorPosition().row - editors[1^active].getCursorPosition().row;
      editors[1^active].selection.moveCursorBy(times, 0);
    }
    
    function shouldJump(dir){
      //if selection is one row
      rows = editor.$getSelectedRows()
      if(rows.last == rows.first){
        //if in editor[0] && in last position
       if(dir == 'r' && editor == editors[0] && editor.getCursorPosition().column == editor.session.getDocumentLastRowColumnPosition(editor.getCursorPosition()).column)
          return true;
        //if in editor[1] && in first position
        else if(dir == 'l' && editor == editors[1] && editor.getCursorPosition().column == 0) 
          return true;
        
      }
      return false;
    }
    
    canon.addCommand({
      name: "_return",
      bindKey : bindKey("return","return"),
      exec: function(env, args, request) {
        //TODO: if typing in [1], previous row is blank, correspoding [0] row is blank
        if(false){//(editors[0].session.doc.$lines[editors[0].session.doc.$lines.length-1] == "" && editors[1].session.doc.$lines[editors[1].session.doc.$lines.length-1] == "") {
          //do nothing
        }
        else {//if typing in [0], previous row is blank, corresponding [1] row is blank
          //do nothing
          editor.insert('\n');
        
          // if in editor 1, also add newline in editor 0
          if(editor == editors[1]){ 
            if(editors[1].$getSelectedRows().last+1 != editors[1].session.doc.$lines.length && editors[0].session.doc.$lines.length <= editors[1].session.doc.$lines.length){
            //if we're replacing content
              // TODO: remove lines
            //otherwise, add a line
            editors[0].gotoLine(editors[1].$getSelectedRows().last+1);
            editors[0].insert('\n');
            editors[0].gotoLine(editors[1].$getSelectedRows().last+1);
            }
          }
        }
        syncCursor();
      }
    });
    
    canon.addCommand({
        name: "_golineup",
        bindKey: bindKey("Up", "Up|Ctrl-P"),
        exec: function(env, args, request) { editor.navigateUp(args.times); syncCursor();}
    });
    
    canon.addCommand({
        name: "_golinedown",
        bindKey: bindKey("Down", "Down|Ctrl-N"),
        exec: function(env, args, request) { editor.navigateDown(args.times); syncCursor(); }
    });
    
    canon.addCommand({
        name: "gotoleft",
        bindKey: bindKey("Left", "Left|Ctrl-B"),
        exec: function(env, args, request) { shouldJump('l') ? jumpLeft()  : env.editor.navigateLeft(args.times); syncCursor();}
    });
    
    canon.addCommand({
        name: "gotoright",
        bindKey: bindKey("Right", "Right|Ctrl-F"),
        exec: function(env, args, request) { shouldJump('r') ? jumpRight() : env.editor.navigateRight(args.times); syncCursor();}
    });
    

    canon.addCommand({
      name: "_indent",
      bindKey: bindKey("Tab","Tab"),
      exec: function(env, args, request) {
        if (editor.$readOnly)
          return;
                
        if(shouldJump('r'))
          jumpRight();
        else { // indent
          var rows = editor.$getSelectedRows();
          editor.session.indentRows(rows.first, rows.last, "\t");
        }
      }
    });
  
    canon.addCommand({
      name: "_outdent",
      bindKey: bindKey("Shift-Tab","Shift-Tab"),
      exec: function(env, args, request) {
        if (editor.$readOnly)
          return;
          
        var rows = editor.$getSelectedRows();
        
        if(shouldJump('l'))
          jumpLeft();
        else // outdent
          editor.blockOutdent();
      }
    });
    
    canon.addCommand({
      name: "_backspace",
      bindKey: bindKey(
          "Ctrl-Backspace|Command-Backspace|Option-Backspace|Shift-Backspace|Backspace",
          "Ctrl-Backspace|Command-Backspace|Shift-Backspace|Backspace|Ctrl-H"
      ),
      exec: function(env, args, request) {
        //if in editors[1] and this line and equivalent line are blank
        if(editor == editors[1] && editors[0].session.getDocumentLastRowColumnPosition(editors[1].getCursorPosition()).column == 0 && editors[1].session.getDocumentLastRowColumnPosition(editors[1].getCursorPosition()).column == 0){    
          editors[0].moveCursorTo(editors[1].getCursorPosition().row+1, 0);
          editors[0].removeLeft();
        }
        editor.removeLeft(); //default
        syncCursor();
      }
    });
    
  });
  
});