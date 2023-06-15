
int odd_series(int p){ 
int j=0;
 for (int i=0 ; i<p; i++){
   if(i%2)
     j += i;
   else
     j++;
 }
 return j;
}


