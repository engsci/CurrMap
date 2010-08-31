var labelType, useGradients, nativeTextSupport, animate, rg, st, json_data, json_data2;

(function() {
  var ua = navigator.userAgent,
      iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
      typeOfCanvas = typeof HTMLCanvasElement,
      nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
      textSupport = nativeCanvasSupport 
        && (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
  //I'm setting this based on the fact that ExCanvas provides text support for IE
  //and that as of today iPhone/iPad current text support is lame
  labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
  nativeTextSupport = labelType == 'Native';
  useGradients = nativeCanvasSupport;
  animate = !(iStuff || !nativeCanvasSupport);
})();

var Log = {
  elem: false,
  write: function(text){
    if (!this.elem)
      this.elem = document.getElementById('log');
    this.elem.innerHTML = text;
    this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
  }
};

function log(obj){
	if('console' in window && 'log'  in window.console){
		console.log(obj);
	}
}

function init(){
    //init data
	log("hi");
	
	var s_option = $jit.id('st'), 
    r_option = $jit.id('rg');
	
    
    function changeHandler() {
        if(this.checked) {
			//r_option.disabled = s_option.disabled = true;
			log(this.id);
			if (this.id == 'rg'){
				//st = null;
				st.canvas.getCtx.globalAlpha = 0;
				st.canvas.clear();
				document.getElementById('jviz').style.display = 'none';
				document.getElementById('jbiz').style.display = 'inline';
				spaceTree(json_data);
			}else{
				//rg = null;
				rg.canvas.getCtx.globalAlpha = 0;
				rg.canvas.clear();
				document.getElementById('jbiz').style.display = 'none';
				document.getElementById('jviz').style.display = 'inline';
				rgraph(json_data2);
			}
            //rg(json);
        }
    };
    
    r_option.onchange = s_option.onchange = changeHandler;
	
	//var json ='{"name":"John"}';
	jQuery.getJSON('/../tok', function (data){
	json_data = data;
	spaceTree(data);
	});
	jQuery.getJSON('/../tok', function (data2){
	json_data2 = data2;
	rgraph(data2);
	});
	//console.log("json"+json);
	
    //end
}

		
function spaceTree (json){
		st = new $jit.ST({
        //id of viz container element
        injectInto: 'jviz',
        //set duration for the animation
        duration: 100,
        //set animation transition type
        transition: $jit.Trans.Quart.easeInOut,
        //set distance between node and its children
        levelDistance: 40,
        //enable panning
        Navigation: {
          enable:true,
          panning:false
        },
        //set node and edge styles
        //set overridable=true for styling individual
        //nodes or edges
        Node: {
            height: 20,
            width: 90,
            type: 'rectangle',
            color: '#aaa',
            overridable: true
        },
        
        Edge: {
            type: 'bezier',
            overridable: true
        },
        
        onBeforeCompute: function(node){
            Log.write("loading " + node.name);
        },
        
        onAfterCompute: function(){
            Log.write("done");
        },
        
		
        //This method is called on DOM label creation.
        //Use this method to add event handlers and styles to
        //your node.
        onCreateLabel: function(label, node){
            label.id = node.id;            
            label.innerHTML = node.name;
            label.onclick = function(){
           	  st.onClick(node.id);
            };
            //set label styles
            var style = label.style;
			var ruler = document.getElementById("ruler")
			ruler.innerHTML = node.name;
			style.width = (ruler.offsetWidth + 10) + 'px';
            style.height = 17 + 'px';            
            style.cursor = 'pointer';
            style.color = '#333';
            style.fontSize = '0.8em';
            style.textAlign= 'center';
            style.paddingTop = '3px';
        },
        
        //This method is called right before plotting
        //a node. It's useful for changing an individual node
        //style properties before plotting it.
        //The data properties prefixed with a dollar
        //sign will override the global node style properties.
        onBeforePlotNode: function(node){
            //add some color to the nodes in the path between the
            //root node and the selected node.
			var ruler = document.getElementById("ruler")
			ruler.innerHTML = node.name;
			node.data.$width = ruler.offsetWidth + 10;
			if (node.data.$width > 90){
				//node.data.$alpha = 0;
				//node.eachSubnode(function(n) { n.data.$alpha = 0; });
			}
			
			
            if (node.selected) {
                node.data.$color = "#ff7";
            }
            else {
                delete node.data.$color;
                //if the node belongs to the last plotted level
                if(!node.anySubnode("exist")) {
                    //count children number
                    var count = 0;
                    node.eachSubnode(function(n) { count++; });
                    //assign a node color based on
                    //how many children it has
                    node.data.$color = ['#aaa', '#baa', '#caa', '#daa', '#eaa', '#faa'][count];                    
                }
            }
        },
        
        //This method is called right before plotting
        //an edge. It's useful for changing an individual edge
        //style properties before plotting it.
        //Edge data proprties prefixed with a dollar sign will
        //override the Edge global style properties.
        onBeforePlotLine: function(adj){
            if (adj.nodeFrom.selected && adj.nodeTo.selected) {
                adj.data.$color = "#eed";
                adj.data.$lineWidth = 3;
            }
            else {
                delete adj.data.$color;
                delete adj.data.$lineWidth;
            }
        }
    });
    //load json data
    st.loadJSON(json);
    //compute node positions and layout
    st.compute();
    //optional: make a translation of the tree
    st.geom.translate(new $jit.Complex(-200, 0), "current");
    //emulate a click on the root node.
    st.onClick(st.root);
    st.compute();
	st.geom.switchOrientation("top");
    //end
    //Add event handlers to switch to rgraph.
}

function rgraph (json){
		rg = new $jit.RGraph({
        //Where to append the visualization
        injectInto: 'jbiz',
        //Optional: create a background canvas that plots
        //concentric circles.
        background: {
          CanvasStyles: {
            strokeStyle: '#555'
          }
        },
        //Add navigation capabilities:
        //zooming by scrolling and panning.
        Navigation: {
          enable: true,
          panning: true,
          zooming: 10
        },
        //Set Node and Edge styles.
        Node: {
            color: '#ddeeff'
        },
        
        Edge: {
          color: '#C17878',
          lineWidth:1.5
        },

        onBeforeCompute: function(node){
            Log.write("centering " + node.name + "...");
            //Add the relation list in the right column.
            //This list is taken from the data property of each JSON node.
            $jit.id('inner-details').innerHTML = node.data.relation;
        },
        
        onAfterCompute: function(){
            Log.write("done");
        },
        //Add the name of the node in the correponding label
        //and a click handler to move the graph.
        //This method is called once, on label creation.
        onCreateLabel: function(domElement, node){
            domElement.innerHTML = node.name;
            domElement.onclick = function(){
                rg.onClick(node.id);
            };
        },
        //Change some label dom properties.
        //This method is called each time a label is plotted.
        onPlaceLabel: function(domElement, node){
            var style = domElement.style;
            style.display = '';
            style.cursor = 'pointer';

            if (node._depth <= 1) {
                style.fontSize = "0.8em";
                style.color = "#ccc";
            
            } else if(node._depth == 2){
                style.fontSize = "0.7em";
                style.color = "#494949";
            
            } else {
               // style.display = 'none';
            }

            var left = parseInt(style.left);
            var w = domElement.offsetWidth;
            style.left = (left - w / 2) + 'px';
        }
    });
    //load JSON data
    rg.loadJSON(json);
    //trigger small animation
    rg.graph.eachNode(function(n) {
      var pos = n.getPos();
      pos.setc(-200, -200);
    });
    rg.compute('end');
    rg.fx.animate({
      modes:['polar'],
      duration: 2000
    });
    //end
    //append information about the root relations in the right column
    $jit.id('inner-details').innerHTML = rg.graph.getNode(rg.root).data.relation;
//	document.getElementById("jbiz").style.display = "none";

	
	
	
}	 


