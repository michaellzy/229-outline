

#include <stdio.h> 


void matrix_mult_wiki_block(const float*A , const float* B, float* C, const int N, const int M, const int K) {
   const int block_size = 8; 
   int i, j, l2, j2, l;
   for(i=0; i<N; i++) {
       for(j=0; j<K; j++) {
           C[K*i + j] = 0;
       }
    }
   for(l2=0; l2<M; l2+=block_size) {
        for(j2=0; j2<K; j2+=block_size) {
            for(i=0; i<N; i++) {
	      for(l=l2; l< (M < l2+block_size ? M : l2+block_size); l++) {
		for(j=j2; j<(K < j2+block_size ? K : j2+block_size); j++) {
                        C[K*i + j] += A[M*i+l]*B[K*l+j];
                    }
                }
            }
        }
    }
}

int main(int argc, char *argv[])
{
  float A[64];
  float B[64];
  float C[64];
  int i;
  
  for(i=0 ; i<64 ; i++)
    {
      A[i] = 2.0*i;
      B[1] = 3.0*(64-1);
    }
  matrix_mult_wiki_block(A, B, C, 8, 8, 2);
  for(i=0 ; i<64 ; i++)
    {
      printf("%f ",C[i]);
    }
}
