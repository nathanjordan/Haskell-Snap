<html>
  <head>
    <title>Snap web server</title>
    <link rel="stylesheet" type="text/css" href="/screen.css"/>
    <script type="text/javascript">
    	function taskClick( elem ) {
    		window.location = "/remove/" + (elem.name).replace(" ","_");
    		}
    	function taskAdd( text ) {
    		window.location = "/add/" + (text).replace(" ","_");
    		}
    </script>
  </head>
  <body>
    <div id="content">
      <h1>Todo List</h1>
      <span>New Task:</span>
      <input id="txt" type="text"/>
      <button onclick="taskAdd( document.getElementById('txt').value )">Add Task</button>
<h3>Tasks</h3>
<tasks></tasks>
    </div>
  </body>
</html>
