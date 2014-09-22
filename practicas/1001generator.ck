// * Para correr este archivo de manera
// * infinita, edite y ejecute looper.ck
// * En looper.ck edite de la siguiente manera
// * Machine.add(me.dir()+"/300densidad.ck") => int fileID;
// * Luego ejecute looper.ck

// Determinamos una duración para lo que
// va a ser nuestro beat.
500::ms => dur bit;

// Definimos la nota raiz.
28 => int root;

// Hacemos un bajo y le asingamos
// una ganancia (volumen).
SawOsc bass => Envelope e => dac;

// Hacemos un sonido para melodía
// y la pasamos por una reverberación.
TriOsc mel => Envelope eMel => NRev rMel => dac;

// Intervalos que se usarán para los acordes,
// Puede poner tantos elementos como quiera
// en el array.
[0, 3, 7, 12, 14] @=> int notes[];

// Se crean tantos instrumentos como elementos
// del array.
SawOsc chord[notes.cap()];

// Se hace que todos los instrumentos
// pasen por un Gain, Envelope, Nrev, y Pan.
Gain master => Envelope eChord => NRev rCh => Pan2 p => dac;

// ------Mixer-------
0.5 => mel.gain;
0.1 => rMel.mix;
0.2 => bass.gain;
// Ganancia acordes.
0.1 => float initGain;
0.01 => rCh.mix; 

// Se pasan todos los instrumentos por
// la cadena de audio del master.
for( 0 => int i; i < chord.cap(); i++ )
{
 	chord[i] => master;
}

// Un bajo que se ejecuta en corcheas (bit/2)
// y variando la distancia de la nota raiz
// (root -2)(root + 10)etc. Para la última parte
// de la ejecución, que se repite igual 6 veces,
// se hace con un ciclo lógico "until".
fun void bs()
{
	while(true)
	{
		Std.mtof( root -2) => bass.freq;e.keyOn(); bit/2 => now; e.keyOff();
		Std.mtof( root + 10 ) => bass.freq; e.keyOn(); bit/2 => now; e.keyOff();
		Std.mtof( root -2) => bass.freq; e.keyOn(); bit/2 => now; e.keyOff();
		Std.mtof( root + 10 ) => bass.freq; e.keyOn(); bit/2 => now; e.keyOff();
		0 => int i;
		until ( i == 6 )
		{
			Std.mtof( root ) => bass.freq;e.keyOn(); bit/2 => now; e.keyOff();
			Std.mtof( root + 12 ) => bass.freq; e.keyOn(); bit/2 => now; e.keyOff();
			i++;
		}
	}
}
 
// Función para acordes
fun void ch( int root, int notes[], int div1, int div2)
{
	while(true)
	{
		for( 0 => int i; i < notes.cap(); i++)
		{
			Std.mtof(root + notes[i]) => chord[i].freq;
			Math.random2f(0.0, initGain) => chord[i].gain;
			Math.random2f(-1, 1) => p.pan;
		}
		eChord.keyOn();
		bit/div1 => now;
		eChord.keyOff();
		bit/div2 => now;
		
	}
	
}

// Función para la melodia.
fun void ml(int size, int div1, int div2)
{
	while(true)
	{
		// Notas opcionales en una Pentatonica
		[0, 2, 5, 7, 9, 12, 14] @=> int optNotes[];
		// Divisiones del beat opcionales
		[ 1,  2,  3,  4] @=> int optDiv[];

		int notes[size];
		int div[size];

		// Llena un array de notas de manera aleatoria
		for ( 0 => int i; i < size; i++ )
		{
			optNotes[(Math.random2(0, optNotes.cap()-1))] => notes[i];
			optDiv[(Math.random2(0, optDiv.cap()-1))] => div[i];
		}
				
//		Ejecuta la melodía.
		for (0 => int i; i < size; i++)
		{
			eMel.keyOn();
			Std.mtof( root + 24 + notes[i]) => mel.freq;
			bit/div[i] => now;
			eMel.keyOff();
			bit/div[i] => now;
		
		}
	}
}

// Se llaman todas las funciones. 
Drummer dr;
spork~ dr.kk(1);
spork~ dr.sn();
spork~ dr.hh();

// -Bajo
spork~ bs();

// -Acordes
spork~ ch(root+36, notes, 12, 4);

// Melodía
spork~ ml(8, 4, 4);

// Un ciclo infinito para mantener vivos los llamados a las funciones.
while(true)
{
	bit => now;
}