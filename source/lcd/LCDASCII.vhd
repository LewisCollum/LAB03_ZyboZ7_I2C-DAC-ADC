library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package LCDASCII is
	subtype char is unsigned(7 downto 0);
	
	type Uppercase is record 
		A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z: char;
	end record;
	
	type Lowercase is record 
		a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z: char;
	end record;
	
	type Command is record 
		space, colon: char;
	end record;
    
	constant u : Uppercase := (
		A => X"41",
		B => X"42",
		C => X"43",
		D => X"44",
        E => X"45",
        F => X"46",
        G => X"47",
        H => X"48",
        I => X"49",
        J => X"4A",
        K => X"4B",
        L => X"4C",
        M => X"4D",
        N => X"4E",
        O => X"4F",
        P => X"50",
        Q => X"51",
        R => X"52",
        S => X"53",
        T => X"54",
        U => X"55",
        V => X"56",
        W => X"57",
        X => X"58",
        Y => X"59",
        Z => X"5A"
		);
		
	constant l : Lowercase := (
		a => X"61",
        b => X"62",
        c => X"63",
        d => X"64",
        e => X"65",
        f => X"66",
        g => X"67",
        h => X"68",
        i => X"69",
        j => X"6A",
        k => X"6B",
        l => X"6C",
        m => X"6D",
        n => X"6E",
        o => X"6F",
        p => X"70",
        q => X"71",
        r => X"72",
        s => X"73",
        t => X"74",
        u => X"75",
        v => X"76",
        w => X"77",
        x => X"78",
        y => X"79",
        z => X"7A"
		);
	
	constant c : Command := (
		space => X"20",
		colon => X"3A"
		);
end package;
