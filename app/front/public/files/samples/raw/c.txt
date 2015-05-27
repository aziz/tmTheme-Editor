/* stringmerge.c -- Given two sorted files of strings, it creates
 *            a sorted file consisting of all their elements.
 *            The names of the files are passed as command
 *            line parameters.
 */

#include <stdio.h>
#define MAXBUFFER 128

int getline(FILE * fd, char buff[], int nmax){
  /* It reads a line from fd and stores up to nmax of
   * its characters to buff.
   */
  char c;
  int n=0;

  while ((c=getc(fd))!='\n'){
    if(c==EOF)return EOF;
    if(n<nmax)
      buff[n++]=c;
  }
  buff[n]='\0';
  return n;
}

int stringMerge(char filename1[], char filename2[] , char filename3[]) {
  /* Given two sorted files of strings, called filename1 and filename2,
   * it writes their merged sequence to the file filename3.
   * It returns the total number of strings written to filename3.
   */
  FILE *fd1, *fd2, *fd3;
  char buffer1[MAXBUFFER], buffer2[MAXBUFFER];
  int ln1, ln2;
  int n=0;

  if ((fd1=fopen(filename1, "r"))==NULL) {
    perror("fopen");
    exit(1);
  }
  if ((fd2=fopen(filename2, "r"))==NULL) {
    perror("fopen");
    exit(1);
  }
  if ((fd3=fopen(filename3, "w"))==NULL) {
    perror("fopen");
    exit(1);
  }

  ln1 = getline(fd1,buffer1,MAXBUFFER-1);
  ln2 = getline(fd2,buffer2,MAXBUFFER-1);

  while ((ln1!=EOF) && (ln2!=EOF)){
    if (strcmp(buffer1,buffer2)<=0){
      fprintf(fd3, "%s\n", buffer1);
      ln1 = getline(fd1,buffer1,MAXBUFFER-1);
    }else{
      fprintf(fd3, "%s\n", buffer2);
      ln2 = getline(fd2,buffer2,MAXBUFFER-1);
    }
    n++;
  }

  while (ln1!=EOF){
      fprintf(fd3, "%s\n", buffer1);
      ln1=getline(fd1,buffer1,MAXBUFFER-1);
      n++;
  }

  while (ln2!=EOF){
      fprintf(fd3, "%s\n", buffer2);
      ln2=getline(fd2,buffer2,MAXBUFFER-1);
      n++;
  }

  fclose(fd1);
  fclose(fd2);
  fclose(fd3);
  return n;
}

int main(int argc, char *argv[]) {
  if(argc!=4){
    printf("Usage: %s sortedfile1 sortedfile2 mergefile\n", argv[0]);
    exit(0);
  }
  printf("We have %d merged records\n",
   stringMerge(argv[1], argv[2], argv[3]));
}
