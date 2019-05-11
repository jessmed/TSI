#include <iostream>
#include <cstdlib>
#include <fstream>
#include <string>
#include <vector>


using namespace std;

int main()
{
	
    ifstream archivo_entrada("./Mapa_Ej1.txt");
    ofstream archivo_salida;
    
    archivo_salida.open("Problema_Ej1.pddl");
    
    string linea;
    int n;

    

	//Extraemos numero de zonas
    getline(archivo_entrada, linea,':');
	getline(archivo_entrada, linea);
	n = stoi(linea);
   
	
	archivo_salida << "(define (problem Belkan-problem)"<<endl;
	archivo_salida << "\n\t(:domain Belkan-domain)"<<endl;
    
    archivo_salida << "\n\t(:objects";
    for(int i=1;i<=n;i++){
    	archivo_salida << " z"<<i;
	}
	archivo_salida << " - zona";
	archivo_salida <<"\n\t\t\t\tN S W E - orientacion"<<endl;
	archivo_salida <<"\t\t\t\tjugador1 - jugador"<<endl;
	archivo_salida <<"\t\t\t\toscar manzana rosa algoritmo oro - objeto"<<endl;
	archivo_salida <<"\t\t\t\tprincesa principe bruja profesor LeonardoDiCaprio - personaje"<<endl;
	archivo_salida <<"\t)"<<endl;;

	archivo_salida <<"\n\t(:init"<<endl;
	
	

	string z1;
	char c;
	vector<pair<string,string>> obj;  //Vector almacena parejas de objeto y zona donde esta
	vector<string> zonas_v;   		  //Vector almacena zonas conectadas verticalmente
	vector<string> zonas_h;   		  //Vector almacena zonas conectadas horizontalmente

	//Hasta que no encuentra final de fichero
	while(!archivo_entrada.eof()){
		getline(archivo_entrada, linea,' ');  //Coge V o H
		
		
		//Lee conexiones y objetos en lineas verticales
		if(linea == "V"){
			getline(archivo_entrada, linea,' '); //Saltamos flecha
			
			while(c != '\n' && !archivo_entrada.eof()){
			
				getline(archivo_entrada, linea,'['); //Coge zona
				zonas_v.push_back(linea);
				z1 = linea;     //Guarda zona para enlazarlo con objeto si lo hay
				
				
				getline(archivo_entrada, linea,']'); //Coge objeto si lo hay
				if(!linea.empty()){     
					int contador=0;
					int i=0;
					while(linea[i]!='-'){
						contador++;
						i++;
					}
					contador++;
					linea.erase(0,contador);  
					pair<string,string> p1(z1,linea);
					obj.push_back(p1);
				}
				
				archivo_entrada.get(c);
			}
			
		}
		c=' '; //Reiniciamos la variable
		
		//Lee conexiones y objetos en lineas horizontales
		if(linea == "H"){
			getline(archivo_entrada, linea,' '); //Saltamos flecha
			
			while(c != '\n' && !archivo_entrada.eof()){
				
				getline(archivo_entrada, linea,'['); //Coge zona
				//cout << linea;
				zonas_h.push_back(linea);
				z1 = linea;     //Guarda zona para enlazarlo con objeto si lo hay
				
				
				getline(archivo_entrada, linea,']'); //Coge objeto si lo hay
				if(!linea.empty()){   
				  	//Bucle que elimna el nombre de la variable y solo guarda el tipo de variable
					int contador=0;
					int i=0;
					while(linea[i]!='-'){
						contador++;
						i++;
					}
					contador++;
					linea.erase(0,contador);     
					pair<string,string> p1(z1,linea);
					obj.push_back(p1);
				}
				
				archivo_entrada.get(c);
			}
		}
		
		c=' '; //Reiniciamos la variable	
		
	

		/*
		vector<string>::iterator it = zonas_v.begin();
		for(;it != zonas_v.end();it++)
			cout << *it << " ";
		cout << endl;
		
		vector<string>::iterator itt = zonas_h.begin();
		for(;itt != zonas_h.end();itt++)
			cout << *itt << " ";
		cout << endl;
		
		
		
		vector<pair<string,string>>::iterator ite = obj.begin();
		for(;ite != obj.end();ite++)
			cout << (*ite).second <<" ";
		cout << endl<<endl;
		*/

		
		int n_v=zonas_v.size();
		
		for(int i=0;i<n_v;i++){
			if(i+1 < n_v && !zonas_v[i+1].empty()){
				archivo_salida << "\t\t(conexion "<< zonas_v[i] << " " << zonas_v[i+1] << " S" << ")"<<endl;
				archivo_salida << "\t\t(conexion "<< zonas_v[i+1] << " " << zonas_v[i] << " N" << ")"<<endl;
			}
		}
		zonas_v.clear();
		
		int n_h=zonas_h.size();
		
		for(int i=0;i<n_h;i++){
			if(i+1 < n_h && !zonas_h[i+1].empty()){
				archivo_salida << "\t\t(conexion "<< zonas_h[i] << " " << zonas_h[i+1] << " E" << ")"<<endl;
				archivo_salida << "\t\t(conexion "<< zonas_h[i+1] << " " << zonas_h[i] << " W" << ")"<<endl;
			}
		}
		
		zonas_h.clear();
		
	}
	
	//Imprimimos las posiciones iniciales de personajes y objetos
	vector<pair<string,string>>::iterator it2 = obj.begin();
	archivo_salida << endl;
	
	for(;it2!=obj.end();it2++){
		archivo_salida << "\t\t(at " << it2->second << " " << it2->first <<")" <<endl;
	}

	
	archivo_salida << "\n\t\t(ori jugador1 S)"<<endl;
	archivo_salida << "\n\t\t(manoVacia jugador1)"<<endl;
	archivo_salida << "\t)"<<endl;
	archivo_salida << ")";
	
	//NOTA: FALTA plantear posibilidad  sobre si hay un objeto en una zona
	//que sale repetida porque se guarda 2 veces pero 
	archivo_salida.close();
	
	cout<<"Mapa representado con exito!!";
	return(0);
}
