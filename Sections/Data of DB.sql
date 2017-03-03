// Activar BDD
var db = openDatabase('mydb', '1.0', 'my first database', 2 * 1024 * 1024);

// Insertar datos
db.transaction(function (tx) {
  tx.executeSql('CREATE TABLE IF NOT EXISTS foo (id unique, text)');
  tx.executeSql('INSERT INTO foo (id, text) VALUES (1, "bar")');
  tx.executeSql('insert into foo (id, text) values (?, ?)', [2, "synergies"]);
});

// Select datos
db.transaction(function (tx) {
	tx.executeSql('SELECT * FROM foo', [], function (tx, results) {
	  var len = results.rows.length, i;
	  for (i = 0; i < len; i++) {
		console.log (results.rows.item(i).text);
	  }
	});
});

// Get nombre de tablas de nuestra bdd
db.transaction(function (tx) {
	tx.executeSql("SELECT * FROM sqlite_master where type='table'", [], function (tx, results) {
	  var len = results.rows.length, i;
	  for (i = 0; i < len; i++) {
		console.log(results.rows.item(i).tbl_name);
	  }
	});
});

// Get nombre de campos de nuestra tablas - Funcion
db.transaction(function (tx) {
	tx.executeSql("SELECT sql FROM sqlite_master where name = 'foo';", [], function (tx, results) {  
		var cad = results.rows.item(0).sql;
		
		cad = cad.split("(")[1];
		cad = cad.substr(0, cad.length -1);
		cad = cad.split(", ");

		var array = [];
		for (var i = 0; i < cad.length; i++) {
			array.push( cad[i].split(" ")[0] );
		}
		
		console.log (array);
	});
});

// Get nombre de campos de nuestra tablas - RegEx
db.transaction(function (tx) {
	tx.executeSql("SELECT sql FROM sqlite_master where name = 'foo';", [], function (tx, results) {  
		var cad = results.rows.item(0).sql;

		cad = cad.match(/\(((\w+){1}(\ \w+)*(\,\ )*)+\)/g)[0];
		cad = cad.match(/^\(\w+|\,\ \w+/g)
		
		cad.forEach( function (element, index, array) { 
			array[index] = array[index].replace( /\(|\,\ /g, function () { return ""; } );
		} )

		console.log (cad);
	});
});

// Get nombre de campos de nuestra tablas - RegEx 2
function exec (table, callback) {
	db.transaction(function (tx) {
		tx.executeSql("SELECT sql FROM sqlite_master where name = ?;", [table], function (tx, results) {  
			var cad = results.rows.item(0).sql;

			var array = [];
			cad.replace(/(?:\(\s*|\,\s*)(\w+)/g, function (match, column) {
				array.push(column);
				return "";
			});

			callback (array);
		});
	});	
}
function exito (array) {
	console.log (array);
}
exec ("foo", exito);
