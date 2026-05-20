// Calcul flot de données (defs, uses, def_uses)

// Attention !! Pour que l'algo fonctionne, il faut que : 
// les noms des instructions soient des entiers encodés en chaines,
// les instructions dans le GFC soient rangées séquentiellement (ou en ordre croissant au-moins) 
// à l'intérieur d'un bloc (et dans l'ordre des blocs). 

#include <stdio.h>
#include <stdlib.h>  
#include <string.h>

#define NB_MAX_BLOCKS_CFG 30
#define MAX_LENGTH_NAME_VAR 50
#define MAX_LENGTH_NAME_BLOCK 50
#define MAX_NB_USED_VAR_STATEMENT 10
#define MAX_NB_STATEMENTS_BLOCK 10
#define MAX_NB_NEXT_NODES_STATEMENT 10
#define MAX_NB_PREVIOUS_NODES_STATEMENT 10
#define MAX_DEF (MAX_NB_STATEMENTS_BLOCK*NB_MAX_BLOCKS_CFG)
#define MAX_USE (MAX_NB_USED_VAR_STATEMENT*MAX_NB_STATEMENTS_BLOCK)
#define MAX_DEF_USE (MAX_USE*MAX_DEF*NB_MAX_BLOCKS_CFG)

typedef enum {start_node, middle_node, terminate_node} cfg_graph_type;

typedef struct {
  char name[MAX_LENGTH_NAME_VAR];
} variable;
  
typedef struct {
  char name[MAX_LENGTH_NAME_VAR];
  variable *defined_variable; 
  variable *used_variables[MAX_NB_USED_VAR_STATEMENT];
} statement;
      
typedef struct st_basic_block {
  char name[MAX_LENGTH_NAME_BLOCK];
  statement *statements[MAX_NB_STATEMENTS_BLOCK];  
  struct st_basic_block *next_nodes[MAX_NB_NEXT_NODES_STATEMENT];
  struct st_basic_block *previous_nodes[MAX_NB_PREVIOUS_NODES_STATEMENT];
  cfg_graph_type node_type;
} basic_block;

typedef struct {
  basic_block *blocks[NB_MAX_BLOCKS_CFG];
  int nb_blocks;    
} cfg_type;            // rajout VA


typedef struct {
  variable *var;
  statement *def_statement;
  statement *use_statement;
} def_use_association;

typedef struct {
  variable *var;
  statement *statement;
} var_association;           // rajout VA

typedef struct {
  var_association *def_in[MAX_DEF];
  var_association *def_out[MAX_DEF];
  var_association *use_out[MAX_USE];
  def_use_association *def_use_asso[MAX_DEF_USE];
} def_use_info;           // rajout VA

typedef def_use_info *info_out_cfg[NB_MAX_BLOCKS_CFG];



statement* create_statement(char name_statement[MAX_LENGTH_NAME_VAR], variable *def_var, 
			    variable *used_vars[MAX_NB_USED_VAR_STATEMENT]) {
  statement *stmt;
  int i;
  stmt =(statement*) malloc(sizeof(statement));
  strcpy(stmt->name,name_statement);
  stmt->defined_variable=def_var;
  if (used_vars != NULL) 
    for(i=0;i<MAX_NB_USED_VAR_STATEMENT;i++) stmt->used_variables[i]=used_vars[i];
  else for(i=0;i<MAX_NB_USED_VAR_STATEMENT;i++) stmt->used_variables[i]=NULL;
  return stmt;
}


void print_statement(statement *stmt) {
  printf("---------- Statement : %s\n",stmt->name);
  printf("               with def_var : ");
  if (stmt->defined_variable != NULL) printf("%s",stmt->defined_variable->name);
  printf("\n               with used_vars : ");
  int i=0;
  if (stmt->used_variables != NULL) 
    while ((i<MAX_NB_USED_VAR_STATEMENT)&&((stmt->used_variables[i]) != NULL)) {
      printf("%s ",stmt->used_variables[i]->name);
      i++;
    }
  printf("\n\n");
}


basic_block* create_block(char name_block[MAX_LENGTH_NAME_BLOCK], statement *stmt_block[MAX_NB_STATEMENTS_BLOCK], 
			  basic_block *n_nodes[MAX_NB_NEXT_NODES_STATEMENT], basic_block *p_nodes[MAX_NB_PREVIOUS_NODES_STATEMENT], 
			  cfg_graph_type b_type) {
  basic_block *b;
  int i;
  b = (basic_block*) malloc(sizeof(basic_block));
  strcpy(b-> name,name_block);
  b->node_type = b_type;
  for(i=0;i<MAX_NB_STATEMENTS_BLOCK;i++) b->statements[i] = stmt_block[i];
  if (n_nodes != NULL) for(i=0;i<MAX_NB_NEXT_NODES_STATEMENT;i++) b->next_nodes[i] = n_nodes[i];
  else for(i=0;i<MAX_NB_NEXT_NODES_STATEMENT;i++) b->next_nodes[i] = NULL;
  if (p_nodes != NULL) for(i=0;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) b->previous_nodes[i] = p_nodes[i];
  else for(i=0;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) b->previous_nodes[i] = NULL;
  return b;
}


void print_block(basic_block *b) {
  printf("** Block : %s of type : ",b->name);
  switch (b->node_type) {
  case start_node : printf("start_node \n"); break;
  case middle_node : printf("middle_node \n"); break;
  case terminate_node : printf("terminate_node \n"); break;
  default : printf("\n");
  }

  printf("      with statements : \n");
  int i=0;
  while ((i<MAX_NB_STATEMENTS_BLOCK)&&(b->statements[i] != NULL)) {
    print_statement(b->statements[i]);
    i++;
  }

  printf("      with previous nodes : ");
  i=0;
  if (b->previous_nodes != NULL) 
    while ((i<MAX_NB_PREVIOUS_NODES_STATEMENT)&&(b->previous_nodes[i] != NULL)) {
      printf("%s ",b->previous_nodes[i]->name);
      i++;
    }
  printf("\n");

  printf("      with next nodes : ");
  i=0;
  if (b->next_nodes != NULL) 
    while ((i<MAX_NB_NEXT_NODES_STATEMENT)&&(b->next_nodes[i] != NULL)) {
      printf("%s ",b->next_nodes[i]->name);
      i++;
    }
  printf("\n\n\n");
}


void print_def_use_asso(def_use_association * du) {
  printf("(%s,%s,%s) ",du->var->name,du->def_statement->name,du->use_statement->name); 
}

  
void print_var_asso(var_association * du) {
  printf("(%s,%s) ",du->var->name,du->statement->name);
}


void print_info_def_uses(cfg_type *cfg,info_out_cfg tab) {
  int i,j;
  printf("\n!!!!!!!!!!!!! INFO DEF USES :\n\n");
  for(i=0;i<cfg->nb_blocks;i++) {
    printf("\nInfo def_uses block %d :",i+1);
    j=0;
    printf("\n   Def_in : "); 
    while((j<MAX_DEF)&&(tab[i]->def_in[j]!=NULL)) {
      print_var_asso(tab[i]->def_in[j]); 
      j++;
    }
    j=0;
    printf("\n   Def_out : "); 
    while((j<MAX_DEF)&&(tab[i]->def_out[j]!=NULL)) {
      print_var_asso(tab[i]->def_out[j]); 
      j++;
    }
    j=0;
    printf("\n   Use_out : ");
    while((j<MAX_USE)&&(tab[i]->use_out[j]!=NULL)) {
      print_var_asso(tab[i]->use_out[j]); 
      j++;
    }
    j=0;
    printf("\n   Def_use_assos : ");    
    while((j<MAX_DEF_USE)&&(tab[i]->def_use_asso[j]!=NULL)) {
      print_def_use_asso(tab[i]->def_use_asso[j]); 
      j++;
    }
    printf("\n\n");
  }
}


void print_file_def_use_asso(FILE* f,def_use_association * du) {
  fprintf(f,"(%s,%s,%s) ",du->var->name,du->def_statement->name,du->use_statement->name); 
}

  
void print_file_var_asso(FILE* f,var_association * du) {
  fprintf(f,"(%s,%s) ",du->var->name,du->statement->name);
}


void print_file_info_def_uses(int n,cfg_type *cfg,info_out_cfg tab) {
  int i,j;
  char nom[10];
  printf("\n Veuillez donner le nom du fichier de sauvegarde des résultats : ");
  scanf("%s",nom);
  FILE *f = fopen(nom, "w");
  fprintf(f,"INFO DEF USES pour le programme de choix numéro : %d\n\n",n);
  for(i=0;i<cfg->nb_blocks;i++) {
    fprintf(f,"\nInfo def_uses block %d :",i+1);
    j=0;
    fprintf(f,"\n   Def_in : "); 
    while((j<MAX_DEF)&&(tab[i]->def_in[j]!=NULL)) {
      print_file_var_asso(f,tab[i]->def_in[j]); 
      j++;
    }
    j=0;
    fprintf(f,"\n   Def_out : "); 
    while((j<MAX_DEF)&&(tab[i]->def_out[j]!=NULL)) {
      print_file_var_asso(f,tab[i]->def_out[j]); 
      j++;
    }
    j=0;
    fprintf(f,"\n   Use_out : ");
    while((j<MAX_USE)&&(tab[i]->use_out[j]!=NULL)) {
      print_file_var_asso(f,tab[i]->use_out[j]); 
      j++;
    }
    j=0;
    fprintf(f,"\n   Def_use_assos : ");    
    while((j<MAX_DEF_USE)&&(tab[i]->def_use_asso[j]!=NULL)) {
      print_file_def_use_asso(f,tab[i]->def_use_asso[j]); 
      j++;
    }
  }
  fclose(f);
}


void print_cfg(cfg_type *cfg) {
  printf("\nCFG with %d blocks :\n\n",cfg->nb_blocks);
  int i;
  for(i=0;i<(cfg->nb_blocks);i++) print_block(cfg->blocks[i]);
}

 
/**********************************************************************/


// modèle de l'exemple
cfg_type* create_cfg_exemple(void) {
  cfg_type *cfg;     
  basic_block *b1,*b2,*b3,*b4,*b5,*b6,*b7,*b8;
  statement *st1,*st2,*st3,*st4,*st5,*st6,*st7,*st8,*st9,*st10,*st11;
  variable *va,*vb,*vc,*vd;
  variable *used_vars3[MAX_NB_USED_VAR_STATEMENT],
    *used_vars4[MAX_NB_USED_VAR_STATEMENT],*used_vars5[MAX_NB_USED_VAR_STATEMENT],
    *used_vars6[MAX_NB_USED_VAR_STATEMENT],*used_vars7[MAX_NB_USED_VAR_STATEMENT],
    *used_vars8[MAX_NB_USED_VAR_STATEMENT],*used_vars9[MAX_NB_USED_VAR_STATEMENT],
    *used_vars10[MAX_NB_USED_VAR_STATEMENT],*used_vars11[MAX_NB_USED_VAR_STATEMENT];
  statement *stmt_block1[MAX_NB_STATEMENTS_BLOCK],*stmt_block2[MAX_NB_STATEMENTS_BLOCK],
    *stmt_block3[MAX_NB_STATEMENTS_BLOCK],*stmt_block4[MAX_NB_STATEMENTS_BLOCK],
    *stmt_block5[MAX_NB_STATEMENTS_BLOCK],*stmt_block6[MAX_NB_STATEMENTS_BLOCK],
    *stmt_block7[MAX_NB_STATEMENTS_BLOCK],*stmt_block8[MAX_NB_STATEMENTS_BLOCK];
  basic_block *n_nodes1[MAX_NB_NEXT_NODES_STATEMENT],*n_nodes2[MAX_NB_NEXT_NODES_STATEMENT],
    *n_nodes3[MAX_NB_NEXT_NODES_STATEMENT],*n_nodes4[MAX_NB_NEXT_NODES_STATEMENT],
    *n_nodes5[MAX_NB_NEXT_NODES_STATEMENT],*n_nodes6[MAX_NB_NEXT_NODES_STATEMENT],
    *n_nodes7[MAX_NB_NEXT_NODES_STATEMENT];
  basic_block *p_nodes2[MAX_NB_PREVIOUS_NODES_STATEMENT],*p_nodes3[MAX_NB_PREVIOUS_NODES_STATEMENT],
    *p_nodes4[MAX_NB_PREVIOUS_NODES_STATEMENT],*p_nodes5[MAX_NB_PREVIOUS_NODES_STATEMENT],
    *p_nodes6[MAX_NB_PREVIOUS_NODES_STATEMENT],*p_nodes7[MAX_NB_PREVIOUS_NODES_STATEMENT],
    *p_nodes8[MAX_NB_PREVIOUS_NODES_STATEMENT];
  int i;
            
  cfg = (cfg_type*) malloc(sizeof(cfg_type));
  
  cfg->nb_blocks = 8;
  
  va = (variable*) malloc(sizeof(variable));
  strcpy(va->name,"a");
  vb = (variable*) malloc(sizeof(variable));
  strcpy(vb->name,"b");
  vc = (variable*) malloc(sizeof(variable));
  strcpy(vc->name,"c");
  vd = (variable*) malloc(sizeof(variable));
  strcpy(vd->name,"d");
  
  used_vars3[0]=va;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars3[i]=NULL;
  used_vars4[0]=vb;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars4[i]=NULL;
  used_vars5[0]=vc;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars5[i]=NULL;
  used_vars6[0]=vd;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars6[i]=NULL;
  used_vars7[0]=vd;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars7[i]=NULL;
  used_vars8[0]=vc;
  used_vars8[1]=vd;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars8[i]=NULL;
  used_vars9[0]=vc;
  used_vars9[1]=vd;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars9[i]=NULL;
  used_vars10[0]=vd;
  used_vars10[1]=vc;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars10[i]=NULL;
  used_vars11[0]=vc;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars11[i]=NULL;
   
  st1=create_statement("1",va,NULL);
  st2=create_statement("2",vb,NULL);
  st3=create_statement("3",vc,used_vars3);
  st4=create_statement("4",vd,used_vars4);
  st5=create_statement("5",NULL,used_vars5);
  st6=create_statement("6",NULL,used_vars6);
  st7=create_statement("7",NULL,used_vars7);
  st8=create_statement("8",NULL,used_vars8);
  st9=create_statement("9",vc,used_vars9);
  st10=create_statement("10",vd,used_vars10);
  st11=create_statement("11",NULL,used_vars11);

  stmt_block1[0]=st1;
  stmt_block1[1]=st2;
  stmt_block1[2]=st3;
  stmt_block1[3]=st4;
  for(i=4;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block1[i]=NULL;
  stmt_block2[0]=st5;
  for(i=1;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block2[i]=NULL;
  stmt_block3[0]=st6;
  for(i=1;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block3[i]=NULL;
  stmt_block4[0]=st7;
  for(i=1;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block4[i]=NULL;
  stmt_block5[0]=st8;
  for(i=1;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block5[i]=NULL;
  stmt_block6[0]=st9;
  for(i=1;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block6[i]=NULL;
  stmt_block7[0]=st10;
  for(i=1;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block7[i]=NULL;
  stmt_block8[0]=st11;
  for(i=1;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block8[i]=NULL;
    
  b1=create_block("1",stmt_block1,NULL,NULL,start_node);
  b2=create_block("2",stmt_block2,NULL,NULL,middle_node);
  b3=create_block("3",stmt_block3,NULL,NULL,middle_node);
  b4=create_block("4",stmt_block4,NULL,NULL,middle_node);
  b5=create_block("5",stmt_block5,NULL,NULL,middle_node);
  b6=create_block("6",stmt_block6,NULL,NULL,middle_node);
  b7=create_block("7",stmt_block7,NULL,NULL,middle_node);
  b8=create_block("8",stmt_block8,NULL,NULL,terminate_node);
  
  n_nodes1[0]=b2;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes1[i] = NULL;
  n_nodes2[0]=b3;
  n_nodes2[1]=b4;
  for(i=2;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes2[i] = NULL;
  n_nodes3[0]=b4;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes3[i] = NULL;
  n_nodes4[0]=b5;
  n_nodes4[1]=b8;
  for(i=2;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes4[i] = NULL;
  n_nodes5[0]=b6;
  n_nodes5[1]=b7;
  for(i=2;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes5[i] = NULL;
  n_nodes6[0]=b4;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes6[i] = NULL;
  n_nodes7[0]=b4;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes7[i] = NULL;

  p_nodes2[0]=b1;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes2[i] = NULL;
  p_nodes3[0]=b2;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes3[i] = NULL;
  p_nodes4[0]=b2;
  p_nodes4[1]=b3;
  p_nodes4[2]=b6;
  p_nodes4[3]=b7;
  for(i=4;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes4[i] = NULL;
  p_nodes5[0]=b4;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes5[i] = NULL;
  p_nodes6[0]=b5;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes6[i] = NULL;
  p_nodes7[0]=b5;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes7[i] = NULL;
  p_nodes8[0]=b4;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes8[i] = NULL;
  
  cfg->blocks[0]=create_block("1",stmt_block1,n_nodes1,NULL,start_node);
  cfg->blocks[1]=create_block("2",stmt_block2,n_nodes2,p_nodes2,middle_node);
  cfg->blocks[2]=create_block("3",stmt_block3,n_nodes3,p_nodes3,middle_node);
  cfg->blocks[3]=create_block("4",stmt_block4,n_nodes4,p_nodes4,middle_node);
  cfg->blocks[4]=create_block("5",stmt_block5,n_nodes5,p_nodes5,middle_node);
  cfg->blocks[5]=create_block("6",stmt_block6,n_nodes6,p_nodes6,middle_node);
  cfg->blocks[6]=create_block("7",stmt_block7,n_nodes7,p_nodes7,middle_node);
  cfg->blocks[7]=create_block("8",stmt_block8,NULL,p_nodes8,terminate_node);
  
  return cfg;
}


// modèle de l'exo4_5 TD8
cfg_type* create_cfg_exo4_5TD8(void) {
  cfg_type *cfg;     
  basic_block *b1,*b2,*b3,*b4;
  statement *st1,*st2,*st3,*st4,*st5,*st6,*st7,*st8,*st9,*st10,*st11,*st12,*st13,*st14,*st15,*st16,*st17;
  variable *vt1,*vt2,*vm,*vn,*vk,*va,*vu1,*vu2,*ve,*vb,*vc,*vd;
  variable *used_vars1[MAX_NB_USED_VAR_STATEMENT],*used_vars2[MAX_NB_USED_VAR_STATEMENT],
    *used_vars3[MAX_NB_USED_VAR_STATEMENT],
    *used_vars4[MAX_NB_USED_VAR_STATEMENT],*used_vars5[MAX_NB_USED_VAR_STATEMENT],
    *used_vars6[MAX_NB_USED_VAR_STATEMENT],*used_vars7[MAX_NB_USED_VAR_STATEMENT],
    *used_vars8[MAX_NB_USED_VAR_STATEMENT],*used_vars9[MAX_NB_USED_VAR_STATEMENT],
    *used_vars10[MAX_NB_USED_VAR_STATEMENT],*used_vars11[MAX_NB_USED_VAR_STATEMENT],
    *used_vars12[MAX_NB_USED_VAR_STATEMENT],*used_vars13[MAX_NB_USED_VAR_STATEMENT],
    *used_vars15[MAX_NB_USED_VAR_STATEMENT],
    *used_vars16[MAX_NB_USED_VAR_STATEMENT],*used_vars17[MAX_NB_USED_VAR_STATEMENT];
  statement *stmt_block1[MAX_NB_STATEMENTS_BLOCK],*stmt_block2[MAX_NB_STATEMENTS_BLOCK],
    *stmt_block3[MAX_NB_STATEMENTS_BLOCK],*stmt_block4[MAX_NB_STATEMENTS_BLOCK];
  basic_block *n_nodes1[MAX_NB_NEXT_NODES_STATEMENT],*n_nodes2[MAX_NB_NEXT_NODES_STATEMENT],
    *n_nodes3[MAX_NB_NEXT_NODES_STATEMENT];
  basic_block *p_nodes2[MAX_NB_PREVIOUS_NODES_STATEMENT],*p_nodes3[MAX_NB_PREVIOUS_NODES_STATEMENT],
    *p_nodes4[MAX_NB_PREVIOUS_NODES_STATEMENT];
  int i;
            
  cfg = (cfg_type*) malloc(sizeof(cfg_type));
  
  cfg->nb_blocks = 4;
  
  vt1 = (variable*) malloc(sizeof(variable));
  strcpy(vt1->name,"t1");
  vt2 = (variable*) malloc(sizeof(variable));
  strcpy(vt2->name,"t2");
  vm = (variable*) malloc(sizeof(variable));
  strcpy(vm->name,"m");
  vn = (variable*) malloc(sizeof(variable));
  strcpy(vn->name,"n");
  vk = (variable*) malloc(sizeof(variable));
  strcpy(vk->name,"k");
  va = (variable*) malloc(sizeof(variable));
  strcpy(va->name,"a");
  vu1 = (variable*) malloc(sizeof(variable));
  strcpy(vu1->name,"u1");
  vu2 = (variable*) malloc(sizeof(variable));
  strcpy(vu2->name,"u2");
  ve = (variable*) malloc(sizeof(variable));
  strcpy(ve->name,"e");
  vb = (variable*) malloc(sizeof(variable));
  strcpy(vb->name,"b");
  vc = (variable*) malloc(sizeof(variable));
  strcpy(vc->name,"c");
  vd = (variable*) malloc(sizeof(variable));
  strcpy(vd->name,"d");
  
  used_vars1[0]=vm;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars1[i]=NULL;
  used_vars2[0]=vm;
  used_vars2[1]=vn;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars2[i]=NULL;
  used_vars3[0]=va;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars3[i]=NULL;
  used_vars4[0]=vu1;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars4[i]=NULL;
  used_vars5[0]=vc;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars5[i]=NULL;
  used_vars6[0]=vc;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars6[i]=NULL;
  used_vars7[0]=vt1;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars7[i]=NULL;
  used_vars8[0]=vt2;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars8[i]=NULL;
  used_vars9[0]=va;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars9[i]=NULL;
  used_vars10[0]=vd;
  used_vars10[1]=vu1;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars10[i]=NULL;
  used_vars11[0]=vu2;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars11[i]=NULL;
  used_vars12[0]=vc;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars12[i]=NULL;
  used_vars13[0]=vm;
  used_vars13[1]=vn;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars13[i]=NULL;
  used_vars15[0]=vm;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars15[i]=NULL;
  used_vars16[0]=vc;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars16[i]=NULL;
  used_vars17[0]=va;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars17[i]=NULL;
  
  st1=create_statement("1",vt1,used_vars1);
  st2=create_statement("2",vt2,used_vars2);
  st3=create_statement("3",vk,used_vars3);
  st4=create_statement("4",va,used_vars4);
  st5=create_statement("5",ve,used_vars5);
  st6=create_statement("6",vb,used_vars6);
  st7=create_statement("7",vt1,used_vars7);
  st8=create_statement("8",vt2,used_vars8);
  st9=create_statement("9",vd,used_vars9);
  st10=create_statement("10",NULL,used_vars10);
  st11=create_statement("11",va,used_vars11);
  st12=create_statement("12",vd,used_vars12);
  st13=create_statement("13",vc,used_vars13);
  st14=create_statement("14",NULL,NULL);
  st15=create_statement("15",vt1,used_vars15);
  st16=create_statement("16",vb,used_vars16);
  st17=create_statement("17",vc,used_vars17);

  stmt_block1[0]=st1;
  stmt_block1[1]=st2;
  stmt_block1[2]=st3;
  stmt_block1[3]=st4;
  stmt_block1[4]=st5;
  for(i=5;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block1[i]=NULL;
  stmt_block2[0]=st6;
  stmt_block2[1]=st7;
  stmt_block2[2]=st8;
  stmt_block2[3]=st9;
  stmt_block2[4]=st10;
  for(i=5;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block2[i]=NULL;
  stmt_block3[0]=st11;
  stmt_block3[1]=st12;
  stmt_block3[2]=st13;
  stmt_block3[3]=st14;
  for(i=4;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block3[i]=NULL;
  stmt_block4[0]=st15;
  stmt_block4[1]=st16;
  stmt_block4[2]=st17;
  for(i=3;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block4[i]=NULL;
    
  b1=create_block("1",stmt_block1,NULL,NULL,start_node);
  b2=create_block("2",stmt_block2,NULL,NULL,middle_node);
  b3=create_block("3",stmt_block3,NULL,NULL,middle_node);
  b4=create_block("4",stmt_block4,NULL,NULL,terminate_node);
  
  n_nodes1[0]=b2;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes1[i] = NULL;
  n_nodes2[0]=b3;
  n_nodes2[1]=b4;
  for(i=2;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes2[i] = NULL;
  n_nodes3[0]=b2;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes3[i] = NULL;
  
  p_nodes2[0]=b1;
  p_nodes2[1]=b3;
  for(i=2;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes2[i] = NULL;
  p_nodes3[0]=b2;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes3[i] = NULL;
  p_nodes4[0]=b2;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes4[i] = NULL;
  
  cfg->blocks[0]=create_block("1",stmt_block1,n_nodes1,NULL,start_node);
  cfg->blocks[1]=create_block("2",stmt_block2,n_nodes2,p_nodes2,middle_node);
  cfg->blocks[2]=create_block("3",stmt_block3,n_nodes3,p_nodes3,middle_node);
  cfg->blocks[3]=create_block("4",stmt_block4,NULL,p_nodes4,terminate_node);
  
  return cfg;
}


// modèle de l'exo6 TD8
cfg_type* create_cfg_exo6TD8(void) {
  cfg_type *cfg;     
  basic_block *b1,*b2,*b3,*b4,*b5,*b6,*b7;
  statement *st1,*st2,*st3,*st4,*st5,*st6,*st7,*st8,*st9,*st10,*st11,*st12,*st13,*st14,*st15;
  variable *va,*vm,*vb,*vn,*vx,*vy,*vt,*vu,*vv,*vz;
  variable *used_vars1[MAX_NB_USED_VAR_STATEMENT],*used_vars2[MAX_NB_USED_VAR_STATEMENT],
    *used_vars3[MAX_NB_USED_VAR_STATEMENT],
    *used_vars4[MAX_NB_USED_VAR_STATEMENT],*used_vars5[MAX_NB_USED_VAR_STATEMENT],
    *used_vars6[MAX_NB_USED_VAR_STATEMENT],*used_vars7[MAX_NB_USED_VAR_STATEMENT],
    *used_vars9[MAX_NB_USED_VAR_STATEMENT],*used_vars10[MAX_NB_USED_VAR_STATEMENT],
    *used_vars12[MAX_NB_USED_VAR_STATEMENT],*used_vars13[MAX_NB_USED_VAR_STATEMENT],
    *used_vars14[MAX_NB_USED_VAR_STATEMENT],*used_vars15[MAX_NB_USED_VAR_STATEMENT];
  statement *stmt_block1[MAX_NB_STATEMENTS_BLOCK],*stmt_block2[MAX_NB_STATEMENTS_BLOCK],
    *stmt_block3[MAX_NB_STATEMENTS_BLOCK],*stmt_block4[MAX_NB_STATEMENTS_BLOCK],
    *stmt_block5[MAX_NB_STATEMENTS_BLOCK],*stmt_block6[MAX_NB_STATEMENTS_BLOCK],
    *stmt_block7[MAX_NB_STATEMENTS_BLOCK];
  basic_block *n_nodes1[MAX_NB_NEXT_NODES_STATEMENT],*n_nodes2[MAX_NB_NEXT_NODES_STATEMENT],
    *n_nodes3[MAX_NB_NEXT_NODES_STATEMENT],*n_nodes4[MAX_NB_NEXT_NODES_STATEMENT],
    *n_nodes5[MAX_NB_NEXT_NODES_STATEMENT],*n_nodes6[MAX_NB_NEXT_NODES_STATEMENT];
  basic_block *p_nodes2[MAX_NB_PREVIOUS_NODES_STATEMENT],*p_nodes3[MAX_NB_PREVIOUS_NODES_STATEMENT],
    *p_nodes4[MAX_NB_PREVIOUS_NODES_STATEMENT],*p_nodes5[MAX_NB_PREVIOUS_NODES_STATEMENT],
    *p_nodes6[MAX_NB_PREVIOUS_NODES_STATEMENT],*p_nodes7[MAX_NB_PREVIOUS_NODES_STATEMENT];
  int i;
            
  cfg = (cfg_type*) malloc(sizeof(cfg_type));
  
  cfg->nb_blocks = 7;
  
  va = (variable*) malloc(sizeof(variable));
  strcpy(va->name,"a");
  vm = (variable*) malloc(sizeof(variable));
  strcpy(vm->name,"m");
  vb = (variable*) malloc(sizeof(variable));
  strcpy(vb->name,"b");
  vn = (variable*) malloc(sizeof(variable));
  strcpy(vn->name,"n");
  vx = (variable*) malloc(sizeof(variable));
  strcpy(vx->name,"x");
  vy = (variable*) malloc(sizeof(variable));
  strcpy(vy->name,"y");
  vt = (variable*) malloc(sizeof(variable));
  strcpy(vt->name,"t");
  vu = (variable*) malloc(sizeof(variable));
  strcpy(vu->name,"u");
  vv = (variable*) malloc(sizeof(variable));
  strcpy(vv->name,"v");
  vz = (variable*) malloc(sizeof(variable));
  strcpy(vz->name,"z");
  
  used_vars1[0]=vm;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars1[i]=NULL;
  used_vars2[0]=vn;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars2[i]=NULL;
  used_vars3[0]=vx;
  used_vars3[1]=vy;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars3[i]=NULL;
  used_vars4[0]=vx;
  used_vars4[1]=vm;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars4[i]=NULL;
  used_vars5[0]=va;
  used_vars5[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars5[i]=NULL;
  used_vars6[0]=va;
  used_vars6[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars6[i]=NULL;
  used_vars7[0]=vx;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars7[i]=NULL;
  used_vars9[0]=va;
  used_vars9[1]=vz;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars9[i]=NULL;
  used_vars10[0]=va;
  used_vars10[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars10[i]=NULL;
  used_vars12[0]=va;
  used_vars12[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars12[i]=NULL;
  used_vars13[0]=va;
  used_vars13[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars13[i]=NULL;
  used_vars14[0]=va;
  used_vars14[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars14[i]=NULL;
  used_vars15[0]=vu;
  used_vars15[1]=vv;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars15[i]=NULL;
  
  st1=create_statement("1",va,used_vars1);
  st2=create_statement("2",vb,used_vars2);
  st3=create_statement("3",NULL,used_vars3);
  st4=create_statement("4",NULL,used_vars4);
  st5=create_statement("5",NULL,used_vars5);
  st6=create_statement("6",vx,used_vars6);
  st7=create_statement("7",vy,used_vars7);
  st8=create_statement("8",NULL,NULL);
  st9=create_statement("9",va,used_vars9);
  st10=create_statement("10",vz,used_vars10);
  st11=create_statement("11",NULL,NULL);
  st12=create_statement("12",vx,used_vars12);
  st13=create_statement("13",vt,used_vars13);
  st14=create_statement("14",vv,used_vars14);
  st15=create_statement("15",vu,used_vars15);
  
  stmt_block1[0]=st1;
  stmt_block1[1]=st2;
  stmt_block1[2]=st3;
  for(i=3;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block1[i]=NULL;
  stmt_block2[0]=st4;
  for(i=1;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block2[i]=NULL;
  stmt_block3[0]=st5;
  for(i=1;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block3[i]=NULL;
  stmt_block4[0]=st6;
  stmt_block4[1]=st7;
  stmt_block4[2]=st8;
  for(i=3;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block4[i]=NULL;
  stmt_block5[0]=st9;
  stmt_block5[1]=st10;
  stmt_block5[2]=st11;
  for(i=3;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block5[i]=NULL;
  stmt_block6[0]=st12;
  stmt_block6[1]=st13;
  for(i=2;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block6[i]=NULL;
  stmt_block7[0]=st14;
  stmt_block7[1]=st15;
  for(i=2;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block7[i]=NULL;
    
  b1=create_block("1",stmt_block1,NULL,NULL,start_node);
  b2=create_block("2",stmt_block2,NULL,NULL,middle_node);
  b3=create_block("3",stmt_block3,NULL,NULL,middle_node);
  b4=create_block("4",stmt_block4,NULL,NULL,middle_node);
  b5=create_block("5",stmt_block5,NULL,NULL,middle_node);
  b6=create_block("6",stmt_block6,NULL,NULL,middle_node);
  b7=create_block("7",stmt_block7,NULL,NULL,terminate_node);
  
  n_nodes1[0]=b2;
  n_nodes1[1]=b3;
  for(i=2;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes1[i] = NULL;
  n_nodes2[0]=b5;
  n_nodes2[1]=b3;
  for(i=2;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes2[i] = NULL;
  n_nodes3[0]=b6;
  n_nodes3[1]=b4;
  for(i=2;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes3[i] = NULL;
  n_nodes4[0]=b7;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes4[i] = NULL;
  n_nodes5[0]=b7;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes5[i] = NULL;
  n_nodes6[0]=b7;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes6[i] = NULL;
  
  p_nodes2[0]=b1;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes2[i] = NULL;
  p_nodes3[0]=b1;
  p_nodes3[1]=b2;
  for(i=2;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes3[i] = NULL;
  p_nodes4[0]=b3;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes4[i] = NULL;
  p_nodes5[0]=b2;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes5[i] = NULL;
  p_nodes6[0]=b3;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes6[i] = NULL;
  p_nodes7[0]=b4;
  p_nodes7[1]=b5;
  p_nodes7[2]=b6;
  for(i=3;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes7[i] = NULL;
  
  cfg->blocks[0]=create_block("1",stmt_block1,n_nodes1,NULL,start_node);
  cfg->blocks[1]=create_block("2",stmt_block2,n_nodes2,p_nodes2,middle_node);
  cfg->blocks[2]=create_block("3",stmt_block3,n_nodes3,p_nodes3,middle_node);
  cfg->blocks[3]=create_block("4",stmt_block4,n_nodes4,p_nodes4,middle_node);
  cfg->blocks[4]=create_block("5",stmt_block5,n_nodes5,p_nodes5,middle_node);
  cfg->blocks[5]=create_block("6",stmt_block6,n_nodes6,p_nodes6,middle_node);
  cfg->blocks[6]=create_block("7",stmt_block7,NULL,p_nodes7,terminate_node);
  
  return cfg;
}


// modèle de l'exo7 TD8
cfg_type* create_cfg_exo7TD8(void) {
  cfg_type *cfg;     
  basic_block *b1,*b2,*b3,*b4,*b5,*b6;
  statement *st1,*st2,*st3,*st4,*st5,*st6,*st7,*st8,*st9,*st10,*st11,*st12,*st13,*st14,*st15,
    *st16,*st17,*st18,*st19,*st20,*st21,*st22,*st23;
  variable *va,*vb,*vx,*vy,*vi,*vd,*ve,*vz,*vc;
  variable *used_vars1[MAX_NB_USED_VAR_STATEMENT],*used_vars2[MAX_NB_USED_VAR_STATEMENT],
    *used_vars3[MAX_NB_USED_VAR_STATEMENT],*used_vars4[MAX_NB_USED_VAR_STATEMENT],
    *used_vars5[MAX_NB_USED_VAR_STATEMENT],*used_vars6[MAX_NB_USED_VAR_STATEMENT],
    *used_vars8[MAX_NB_USED_VAR_STATEMENT],
    *used_vars9[MAX_NB_USED_VAR_STATEMENT],*used_vars10[MAX_NB_USED_VAR_STATEMENT],
    *used_vars11[MAX_NB_USED_VAR_STATEMENT],*used_vars12[MAX_NB_USED_VAR_STATEMENT],
    *used_vars13[MAX_NB_USED_VAR_STATEMENT],*used_vars14[MAX_NB_USED_VAR_STATEMENT],
    *used_vars15[MAX_NB_USED_VAR_STATEMENT],*used_vars16[MAX_NB_USED_VAR_STATEMENT],
    *used_vars18[MAX_NB_USED_VAR_STATEMENT],
    *used_vars19[MAX_NB_USED_VAR_STATEMENT],*used_vars20[MAX_NB_USED_VAR_STATEMENT],
    *used_vars21[MAX_NB_USED_VAR_STATEMENT],*used_vars22[MAX_NB_USED_VAR_STATEMENT],
    *used_vars23[MAX_NB_USED_VAR_STATEMENT];
  statement *stmt_block1[MAX_NB_STATEMENTS_BLOCK],*stmt_block2[MAX_NB_STATEMENTS_BLOCK],
    *stmt_block3[MAX_NB_STATEMENTS_BLOCK],*stmt_block4[MAX_NB_STATEMENTS_BLOCK],
    *stmt_block5[MAX_NB_STATEMENTS_BLOCK],*stmt_block6[MAX_NB_STATEMENTS_BLOCK];
  basic_block *n_nodes1[MAX_NB_NEXT_NODES_STATEMENT],*n_nodes2[MAX_NB_NEXT_NODES_STATEMENT],
    *n_nodes3[MAX_NB_NEXT_NODES_STATEMENT],*n_nodes4[MAX_NB_NEXT_NODES_STATEMENT],
    *n_nodes5[MAX_NB_NEXT_NODES_STATEMENT];
  basic_block *p_nodes2[MAX_NB_PREVIOUS_NODES_STATEMENT],*p_nodes3[MAX_NB_PREVIOUS_NODES_STATEMENT],
    *p_nodes4[MAX_NB_PREVIOUS_NODES_STATEMENT],*p_nodes5[MAX_NB_PREVIOUS_NODES_STATEMENT],
    *p_nodes6[MAX_NB_PREVIOUS_NODES_STATEMENT];
  int i;
            
  cfg = (cfg_type*) malloc(sizeof(cfg_type));
  
  cfg->nb_blocks = 6;
  
  va = (variable*) malloc(sizeof(variable));
  strcpy(va->name,"a");
  vb = (variable*) malloc(sizeof(variable));
  strcpy(vb->name,"b");
  vx = (variable*) malloc(sizeof(variable));
  strcpy(vx->name,"x");
  vy = (variable*) malloc(sizeof(variable));
  strcpy(vy->name,"y");
  vi = (variable*) malloc(sizeof(variable));
  strcpy(vi->name,"i");
  vd = (variable*) malloc(sizeof(variable));
  strcpy(vd->name,"d");
  ve = (variable*) malloc(sizeof(variable));
  strcpy(ve->name,"e");
  vc = (variable*) malloc(sizeof(variable));
  strcpy(vc->name,"c");
  vz = (variable*) malloc(sizeof(variable));
  strcpy(vz->name,"z");
  
  used_vars1[0]=va;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars1[i]=NULL;
  used_vars2[0]=vx;
  used_vars2[1]=vy;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars2[i]=NULL;
  used_vars3[0]=va;
  used_vars3[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars3[i]=NULL;
  used_vars4[0]=vi;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars4[i]=NULL;
  used_vars5[0]=vb;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars5[i]=NULL;
  used_vars6[0]=vx;
  used_vars6[1]=vy;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars6[i]=NULL;
  used_vars8[0]=vi;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars8[i]=NULL;
  used_vars9[0]=va;
  used_vars9[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars9[i]=NULL;
  used_vars10[0]=vz;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars10[i]=NULL;
  used_vars11[0]=va;
  used_vars11[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars11[i]=NULL;
  used_vars12[0]=vi;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars12[i]=NULL;
  used_vars13[0]=vz;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars13[i]=NULL;
  used_vars14[0]=vx;
  used_vars14[1]=vy;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars14[i]=NULL;
  used_vars15[0]=va;
  used_vars15[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars15[i]=NULL;
  used_vars16[0]=vz;
  used_vars16[1]=vd;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars16[i]=NULL;
  used_vars18[0]=va;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars18[i]=NULL;
  used_vars19[0]=vi;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars19[i]=NULL;
  used_vars20[0]=vx;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars20[i]=NULL;
  used_vars21[0]=vx;
  used_vars21[1]=vy;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars21[i]=NULL;
  used_vars22[0]=vz;
  for(i=1;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars22[i]=NULL;
  used_vars23[0]=va;
  used_vars23[1]=vb;
  for(i=2;i<MAX_NB_USED_VAR_STATEMENT;i++) used_vars23[i]=NULL;
  
  st1=create_statement("1",vy,used_vars1);
  st2=create_statement("2",va,used_vars2);
  st3=create_statement("3",vx,used_vars3);
  st4=create_statement("4",vy,used_vars4);
  st5=create_statement("5",NULL,used_vars5);
  st6=create_statement("6",vz,used_vars6);
  st7=create_statement("7",NULL,NULL);
  st8=create_statement("8",vd,used_vars8);
  st9=create_statement("9",vy,used_vars9);
  st10=create_statement("10",va,used_vars10);
  st11=create_statement("11",vz,used_vars11);
  st12=create_statement("12",vi,used_vars12);
  st13=create_statement("13",NULL,used_vars13);
  st14=create_statement("14",ve,used_vars14);
  st15=create_statement("15",vx,used_vars15);
  st16=create_statement("16",vd,used_vars16);
  st17=create_statement("17",NULL,NULL);
  st18=create_statement("18",vx,used_vars18);
  st19=create_statement("19",vi,used_vars19);
  st20=create_statement("20",NULL,used_vars20);
  st21=create_statement("21",vb,used_vars21);
  st22=create_statement("22",vc,used_vars22);
  st23=create_statement("23",vd,used_vars23);
  
  stmt_block1[0]=st1;
  stmt_block1[1]=st2;
  stmt_block1[2]=st3;
  stmt_block1[3]=st4;
  stmt_block1[4]=st5;
  for(i=5;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block1[i]=NULL;
  stmt_block2[0]=st6;
  stmt_block2[1]=st7;
  for(i=2;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block2[i]=NULL;
  stmt_block3[0]=st8;
  stmt_block3[1]=st9;
  stmt_block3[2]=st10;
  stmt_block3[3]=st11;
  stmt_block3[4]=st12;
  stmt_block3[5]=st13;
  for(i=6;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block3[i]=NULL;
  stmt_block4[0]=st14;
  stmt_block4[1]=st15;
  stmt_block4[2]=st16;
  stmt_block4[3]=st17;
  for(i=4;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block4[i]=NULL;
  stmt_block5[0]=st18;
  stmt_block5[1]=st19;
  stmt_block5[2]=st20;
  for(i=3;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block5[i]=NULL;
  stmt_block6[0]=st21;
  stmt_block6[1]=st22;
  stmt_block6[2]=st23;
  for(i=3;i<MAX_NB_STATEMENTS_BLOCK;i++) stmt_block6[i]=NULL;
    
  b1=create_block("1",stmt_block1,NULL,NULL,start_node);
  b2=create_block("2",stmt_block2,NULL,NULL,middle_node);
  b3=create_block("3",stmt_block3,NULL,NULL,middle_node);
  b4=create_block("4",stmt_block4,NULL,NULL,middle_node);
  b5=create_block("5",stmt_block5,NULL,NULL,middle_node);
  b6=create_block("6",stmt_block6,NULL,NULL,terminate_node);
  
  n_nodes1[0]=b2;
  n_nodes1[1]=b3;
  for(i=2;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes1[i] = NULL;
  n_nodes2[0]=b4;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes2[i] = NULL;
  n_nodes3[0]=b4;
  n_nodes3[1]=b5;
  for(i=2;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes3[i] = NULL;
  n_nodes4[0]=b3;
  for(i=1;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes4[i] = NULL;
  n_nodes5[0]=b4;
  n_nodes5[1]=b6;
  for(i=2;i<MAX_NB_NEXT_NODES_STATEMENT;i++) n_nodes5[i] = NULL;
  
  p_nodes2[0]=b1;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes2[i] = NULL;
  p_nodes3[0]=b1;
  p_nodes3[1]=b4;
  for(i=2;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes3[i] = NULL;
  p_nodes4[0]=b2;
  p_nodes4[1]=b3;
  p_nodes4[2]=b5;
  for(i=3;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes4[i] = NULL;
  p_nodes5[0]=b3;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes5[i] = NULL;
  p_nodes6[0]=b5;
  for(i=1;i<MAX_NB_PREVIOUS_NODES_STATEMENT;i++) p_nodes6[i] = NULL;
  
  cfg->blocks[0]=create_block("1",stmt_block1,n_nodes1,NULL,start_node);
  cfg->blocks[1]=create_block("2",stmt_block2,n_nodes2,p_nodes2,middle_node);
  cfg->blocks[2]=create_block("3",stmt_block3,n_nodes3,p_nodes3,middle_node);
  cfg->blocks[3]=create_block("4",stmt_block4,n_nodes4,p_nodes4,middle_node);
  cfg->blocks[4]=create_block("5",stmt_block5,n_nodes5,p_nodes5,middle_node);
  cfg->blocks[5]=create_block("6",stmt_block6,NULL,p_nodes6,terminate_node);
  
  return cfg;
}


/**********************************************************************/
//  Data flow analysis code 
/**********************************************************************/

// rend l'indice dans cfg->blocks du bloc b (à partir de son nom) ou -1
int search_block_in_cfg(cfg_type* cfg, basic_block* b) {
  int i=0, res=-1;
  while((i<cfg->nb_blocks)&&(strcmp(cfg->blocks[i]->name,b->name))) i++;
  if (i<cfg->nb_blocks) res=i;
  return res;
}


// recherche une def de var dans le bloc b (rend 0 ou 1)
int present_def_stmt_block(variable* var, basic_block* b) {
  int i=0;
  while ((i<MAX_NB_STATEMENTS_BLOCK)&&(b->statements[i] != NULL)) {
    if ((b->statements[i]->defined_variable != NULL)&&(!strcmp(b->statements[i]->defined_variable->name, var->name))) 
      return 1;
    else i++;
  }
  return 0;
}


// recherche une def de var dans un ens de defs, à partir de la def d'indice begin (inclue)
// rend -1 ou l'indice dans defs
int present_def_block(variable* var, var_association* defs[MAX_DEF], int begin) {
  int i=begin,res=-1;
  while((i<MAX_DEF)&&(defs[i]!=NULL)) {
    if (!strcmp(defs[i]->var->name,var->name)) {
      res = i;
      i = MAX_DEF;
    }
    i++;
  }
  return res;
}


// recherche une def de var dans la totalité d'un ens de defs 
// rend -1 ou l'indice dans defs
int present_def_all_block(variable* var, var_association* defs[MAX_DEF]) {
  int i=0,res=-1;
  while((i<MAX_DEF)&&(defs[i]!=NULL)) {
    if (!strcmp(defs[i]->var->name,var->name)) {
      res = i;
      i = MAX_DEF;
    }
    i++;
  }
  return res;
}


// rend -1 ou l'indice de l'instruction, dans le bloc d'indice ind_block (dans cfg), avec la dernière def de var
// strictement avant stmt
// rend -1 ou l'indice dans le bloc
int last_def_block(cfg_type* cfg, int ind_block, variable* var, statement* stmt) {
  int i=0,res=-1,end;
  basic_block * b = cfg->blocks[ind_block];
  end = atoi(stmt->name);
  while((i<MAX_NB_STATEMENTS_BLOCK)&&(b->statements[i]!=NULL)) {
    if ((b->statements[i]->defined_variable != NULL)
	&& !strcmp(b->statements[i]->defined_variable->name,var->name)
	&&(atoi(b->statements[i]->name) < end)) 
      if (res == -1) res = i;
      else if (atoi(b->statements[i]->name) > atoi(b->statements[res]->name)) res = i;
    i++;
  }
  return res;
}


// supprime dans defs toutes les defs de var strictement postérieures à l'instruction begin
void delete_def_info_block(variable* var, var_association* defs[MAX_DEF], statement* begin) {
  int i=0,last=MAX_DEF-1;
  while ((last>=0)&&(defs[last]==NULL)) last--;
  if (last==-1) return;
  while((i<MAX_DEF)&&(defs[i]!=NULL)) 
    if (!strcmp(defs[i]->var->name,var->name) && strcmp(defs[i]->statement->name,begin->name)) {
      defs[i]=defs[last];
      defs[last]=NULL;
      last--;                                         
    }
    else i++;
}


// rend l'indice du bloc dans cfg contenant l'instruction stmt, ou NULL
basic_block* get_block_of_inst(cfg_type* cfg, statement* stmt) {
  int i,j;
  for(i=0;i<cfg->nb_blocks;i++) {
    j=0;
    while((j<MAX_NB_STATEMENTS_BLOCK)&&(cfg->blocks[i]->statements[j] != NULL)) {
      if (!strcmp(stmt->name,cfg->blocks[i]->statements[j]->name)) return cfg->blocks[i];
      j++;
    }
  }
  return NULL;
}


// rend l'indice dans le bloc b de l'instruction stmt, ou -1
int get_indice_in_block_of_inst(basic_block* b, statement* stmt) {
  int i=0;
  while((i<MAX_NB_STATEMENTS_BLOCK)&&(b->statements[i] != NULL)) {
    if (stmt == b->statements[i]) return i;
    i++;
  }
  return -1;
}


// teste l'égalité de 2 vars_assos : même nom, même instruction
int are_equals_vars_assos(var_association* asso1, var_association* asso2) {
  return !strcmp(asso1->var->name,asso2->var->name)&&!strcmp(asso1->statement->name,asso2->statement->name);
}


// teste si la def asso est dans l'ens de defs defs
int search_var_asso(var_association* asso, var_association* defs[MAX_DEF]) {
  int i=0;
  while((i<MAX_DEF)&&(defs[i]!=NULL)) {
    if (are_equals_vars_assos(defs[i],asso)) return 1;
    else i++;
  } 
  return 0;
}


// teste l'égalité de 2 def_uses_assos : même nom, même def instruction, même use intruction
int are_equals_def_use_assos(def_use_association* asso1, def_use_association* asso2) {
  return !strcmp(asso1->var->name,asso2->var->name)&&!strcmp(asso1->def_statement->name,asso2->def_statement->name)
    &&!strcmp(asso1->use_statement->name,asso2->use_statement->name);
}


// teste si la def_use_asso asso est dans l'ens de def_uses_assos du
int search_def_use_asso(def_use_association* asso, def_use_association* du[MAX_DEF_USE]) {
  int i=0;
  while((i<MAX_DEF_USE)&&(du[i]!=NULL)) {
    if (are_equals_def_use_assos(du[i],asso)) return 1;
    else i++;
  } 
  return 0;
}


// teste s'il existe un chemin sans def de var dans b, entre def_stmt et use_stmt (exclues)
int block_path_without_redef(variable* var, basic_block* b, statement* def_stmt, statement* use_stmt) {
  int i=0,intdef,intuse;
  intdef = atoi(def_stmt->name);
  intuse = atoi(use_stmt->name);
  while ((i<MAX_NB_STATEMENTS_BLOCK)&&(b->statements[i] != NULL)) {
    if ((b->statements[i]->defined_variable != NULL) 
	&& !strcmp(b->statements[i]->defined_variable->name, var->name)
	&& atoi(b->statements[i]->name)>intdef
	&& atoi(b->statements[i]->name)<intuse) return 0;
    i++;
  }
  return 1;
}


// teste s'il existe un chemin sans def de var dans b, du début jusqu'à use_stmt (exclue)
int block_path_without_redef_start(variable* var, basic_block* b, statement* use_stmt) {
  int i=0,intuse;
  // we check from the first statement (included)
  intuse = atoi(use_stmt->name);
  while ((i<MAX_NB_STATEMENTS_BLOCK)&&(b->statements[i] != NULL)) {
    if ((b->statements[i]->defined_variable != NULL)
	&& !strcmp(b->statements[i]->defined_variable->name, var->name)
	&& atoi(b->statements[i]->name)<intuse) return 0;
    i++;
  }
  return 1;
}


// teste s'il existe un chemin sans def de var dans b, de def_stmt (exclue) à la fin de b
int block_path_without_redef_end(variable* var, basic_block* b, statement* def_stmt) {
  int i=0,intdef;
  intdef = atoi(def_stmt->name);
  // we check until the last statement (included)
  while((i<MAX_NB_STATEMENTS_BLOCK)&&(b->statements[i] != NULL)) {
    if ((b->statements[i]->defined_variable != NULL)
	&& !strcmp(b->statements[i]->defined_variable->name, var->name) 
	&& atoi(b->statements[i]->name)>intdef) return 0;
    i++;
  }
  return 1;
}


// teste s'il existe un chemin sans def de var dans les blocs entre def_block et use_block
// already_seen contient les blocs déjà parcourus pour ne pas risquer de suivre des chemins en cycle
int cfg_path_without_redef(cfg_type* cfg, variable* var, basic_block* def_block, basic_block* use_block, info_out_cfg info_out, basic_block* already_seen[NB_MAX_BLOCKS_CFG]) {
  int i=0,ib,j,absent=1,res;
  basic_block* b;
  // cas chemin direct def-use : cfg-path terminé
  while((i<MAX_NB_PREVIOUS_NODES_STATEMENT)&&(use_block->previous_nodes[i] != NULL)) 
    if (!strcmp(def_block->name,use_block->previous_nodes[i]->name)) return 1;
    else i++;
  i=0;
  while((i<MAX_NB_PREVIOUS_NODES_STATEMENT)&&(use_block->previous_nodes[i] != NULL)) {
    b = use_block->previous_nodes[i];
    ib = search_block_in_cfg(cfg,b);
    if (ib==-1) printf("\n\nError predecessor block not find in cfg !!\n\n");
    else {
      // on recharge b à partir de cfg->blocks car les blocks pointés par previous_nodes ne sont pas 
      // complétement à jour (cf. fcts create-cfg...) 
      b = cfg->blocks[ib];
      // verif si bloc pred b pas déjà parcouru
      j=0;
      while ((j<NB_MAX_BLOCKS_CFG)&&(already_seen[j] != NULL)&&absent) 
	if (!strcmp(already_seen[j]->name,b->name)) absent = 0;
	else j++;
      if (absent) {
	if (j<NB_MAX_BLOCKS_CFG) already_seen[j] = b;
	else printf("\n\nError in cfg_path_without_redef! Loop?\n\n");
	if (!present_def_stmt_block(var,b)) 
	  { res = cfg_path_without_redef(cfg,var,def_block,b,info_out,already_seen);
	    if (res) return 1;}
      }
    }
    i++;
  }
  return 0;
}


// calcule l'info def_use du bloc b au niveau local
void algo_block_local(basic_block* b, def_use_info* du_info) {  
  int i=0,j,nb_defs=0,nb_uses=0,nb_def_uses=0,pres_def,ind_def_stmt;
  statement* stmt;
  var_association* var_asso;
  def_use_association* du_asso;
  while ((i<MAX_NB_STATEMENTS_BLOCK)&&(b->statements[i] != NULL)) {
    //parcours des instructions rangées en ordre séquentiel
    // ecl : algo statement local(b->statements[i],du_info);
    stmt = b->statements[i];
    j=0;
    if (stmt->used_variables != NULL) 
      while ((j<MAX_NB_USED_VAR_STATEMENT)&&(stmt->used_variables[j] != NULL)) {
	// ecl : add use(stmt->used_variables[j],stmt);
	// ecl : add def_use(stmt->used_variables[j],stmt_def,stmt);
	var_asso = (var_association*) malloc(sizeof(var_association)); 
	var_asso->var = stmt->used_variables[j];
	var_asso->statement = stmt;
	du_info->use_out[nb_uses] = var_asso;      // ajout d'une use dans use_out
	nb_uses++;
	ind_def_stmt = present_def_all_block(var_asso->var,du_info->def_out);
	if ((ind_def_stmt != -1) && block_path_without_redef(var_asso->var,b,du_info->def_out[ind_def_stmt]->statement,stmt)) {
	  du_asso = (def_use_association*) malloc(sizeof(def_use_association)); 
	  du_asso->var = var_asso->var;
	  du_asso->def_statement = du_info->def_out[ind_def_stmt]->statement;
	  du_asso->use_statement = stmt;
	  du_info->def_use_asso[nb_def_uses] = du_asso;              // ajout d'une asso def_use
	  nb_def_uses++;
	}
	j++;
      }
    // ecl : add def(stmt->defined_variable,stmt);
    if (stmt->defined_variable != NULL) {
      pres_def = present_def_all_block(stmt->defined_variable,du_info->def_out);
      if (pres_def == -1) {
	var_asso = (var_association*) malloc(sizeof(var_association)); 
	var_asso->var = stmt->defined_variable;
	var_asso->statement = stmt;
	du_info->def_out[nb_defs] = var_asso;            // ajout d'une def dans def_out
	nb_defs++;
      }
      else du_info->def_out[pres_def]->statement = stmt;   // maj/écrasement de la def précédente (de la même var) dans def_out
    }
    i++;
  }
}


// calcule l'info def_use au niveau local pour tout le cfg
void algo_def_uses_local(cfg_type* cfg, info_out_cfg info_out) {
  int i,j;
  def_use_info* dui; 
  printf("\n\n     -> local algo \n");

  // init info_out à vide
  for(i=0;i<(cfg->nb_blocks);i++) {
    dui = (def_use_info*) malloc(sizeof(def_use_info)); 
    info_out[i] = dui; 
    for(j=0;j<MAX_DEF;j++) {
      info_out[i]->def_in[j]=NULL;        
      info_out[i]->def_out[j]=NULL;          
    }  
    for(j=0;j<MAX_USE;j++) info_out[i]->use_out[j]=NULL;        
    for(j=0;j<MAX_DEF_USE;j++) info_out[i]->def_use_asso[j]=NULL;                           
  }
  for(i=cfg->nb_blocks;i<NB_MAX_BLOCKS_CFG;i++) info_out[i]=NULL;  
                                
  for(i=0;i<(cfg->nb_blocks);i++) 
    algo_block_local(cfg->blocks[i],info_out[i]);   
}


// Mise à jour des def_in du bloc d'indice b (dans cfg) avec les def_out de son prédécesseur d'indice p dans cfg
void info_add_defs_in(info_out_cfg info_temp, int b, int p) {
  int ib=0,ip=0;
  if (info_temp[p]->def_out == NULL) return;
  if (info_temp[b]->def_in != NULL) 
    while((ib<MAX_DEF)&&(info_temp[b]->def_in[ib] != NULL)) ib++;
  if (ib == MAX_DEF) {
    printf("\n\nError ! Block %d def_in full. Need to increase MAX_DEF value.\n\n",b);
    return;
  }
  while((ip<MAX_DEF)&&(info_temp[p]->def_out[ip] != NULL)) {
    if (!(search_var_asso(info_temp[p]->def_out[ip],info_temp[b]->def_in)))
      {
	info_temp[b]->def_in[ib] = info_temp[p]->def_out[ip];
	ib++;
      }
    ip++;
  }
}


// teste si le point fixe est atteint, i.e. si tous les blocs ont même def_in et def_out dans info_out_new et info_out
int point_fixe(cfg_type* cfg, info_out_cfg info_out_new,info_out_cfg info_out) {
  int i,j,idem=1; 
  for(i=0;i<(cfg->nb_blocks);i++) {
    j=0;
    while(idem&&(j<MAX_DEF)&&(info_out_new[i]->def_in[j] != NULL)&&(info_out[i]->def_in[j] != NULL)) {
      idem = idem && are_equals_vars_assos(info_out_new[i]->def_in[j],info_out[i]->def_in[j]);
      j++; 
    }
    if (!idem) return 0;
    if (j<MAX_DEF) idem = idem && (info_out_new[i]->def_in[j] == NULL)&&(info_out[i]->def_in[j] == NULL);
    if (!idem) return 0;

    j=0;
    while(idem&&(j<MAX_DEF)&&(info_out_new[i]->def_out[j] != NULL)&&(info_out[i]->def_out[j] != NULL)) {         
      idem = idem && are_equals_vars_assos(info_out_new[i]->def_out[j],info_out[i]->def_out[j]);
      j++;
    }
    if (!idem) return 0;
    if (j<MAX_DEF) idem = idem && (info_out_new[i]->def_out[j] == NULL)&&(info_out[i]->def_out[j] == NULL);
    if (!idem) return 0;
  }
  return idem;
}


// calcule une itération de l'info def_use au niveau global pour le bloc d'indice ind_block dans cfg
void algo_block_global(cfg_type* cfg, info_out_cfg info_out, int ind_block) {  
  int i=0,j=0,k,nb_defs=0,nb_uses=0,nb_def_uses=0,pres_def,ind_def_stmt,ind_use_stmt;
  basic_block* b = cfg->blocks[ind_block];
  int ib = search_block_in_cfg(cfg,b);
  def_use_info* du_info = info_out[ind_block];
  statement* stmt, *def_stmt;
  basic_block* def_block;
  var_association* var_asso;
  def_use_association* du_asso;
  // init/maj de def_out à partir de def_in
  while((j<MAX_DEF)&&(du_info->def_out[j]!=NULL)) j++; 
  while((i<MAX_DEF)&&(du_info->def_in[i]!=NULL)) {
    if (!(search_var_asso(du_info->def_in[i],du_info->def_out))) {
      du_info->def_out[j] = du_info->def_in[i]; 
      j++;
    }
    i++;
  }
  i=0; 
  while ((i<MAX_NB_STATEMENTS_BLOCK)&&(b->statements[i] != NULL)) {
    //parcours des instructions rangées en ordre séquentiel
    // ecl : algo statement global(b->statements[i],du_info); partie uses et defs
    stmt = b->statements[i];
    j=0;
    if (stmt->used_variables != NULL) 
      while ((j<MAX_NB_USED_VAR_STATEMENT)&&(stmt->used_variables[j] != NULL)) {
	// ecl : add use(stmt->used_variables[j],stmt);
	var_asso = (var_association*) malloc(sizeof(var_association)); 
	var_asso->var = stmt->used_variables[j];
	var_asso->statement = stmt;
	du_info->use_out[nb_uses] = var_asso;      // ajout d'une use dans use_out
	nb_uses++;	
	j++;
      }
    // ecl : add def(stmt->defined_variable,stmt);
    if (stmt->defined_variable != NULL) {
      pres_def = present_def_all_block(stmt->defined_variable,du_info->def_out);
      if (pres_def == -1) {
	var_asso = (var_association*) malloc(sizeof(var_association)); 
	var_asso->var = stmt->defined_variable;
	var_asso->statement = stmt;
	du_info->def_out[nb_defs] = var_asso;    // ajout d'une def dans def_out
	nb_defs++;
      }
      else {
	du_info->def_out[pres_def]->statement = stmt;
	// maj/écrasement de la première def de la (même) var
	delete_def_info_block(stmt->defined_variable,du_info->def_out,stmt);
      }
    }
    i++;
  }
  i=0; 
  while (i<nb_uses) {
    //parcours des uses du bloc en cours
    // ecl : algo statement global(du_info); partie def_uses
    var_asso = du_info->use_out[i];
    stmt = var_asso->statement;
    ind_use_stmt = get_indice_in_block_of_inst(b,stmt);
    ind_def_stmt = present_def_all_block(var_asso->var,du_info->def_in);   
    while (ind_def_stmt != -1) {	
      // ecl : add def_use(var_asso->var,stmt_def,stmt);
      def_stmt = du_info->def_in[ind_def_stmt]->statement;
      def_block = get_block_of_inst(cfg,def_stmt);
      if (def_block != NULL) 
	if (!strcmp(b->name,def_block->name)&&(atoi(def_stmt->name) < atoi(stmt->name))) { 
	  if (block_path_without_redef(var_asso->var,b,def_stmt,stmt)) {
	    du_asso = (def_use_association*) malloc(sizeof(def_use_association)); 
	    du_asso->var = var_asso->var;
	    du_asso->def_statement = def_stmt;
	    du_asso->use_statement = stmt;
	    du_info->def_use_asso[nb_def_uses] = du_asso;
	    nb_def_uses++;           // ajout d'une asso def_use intra-bloc
	  }  
	}
	else {
	  basic_block* already_seen[NB_MAX_BLOCKS_CFG];
	  already_seen[0] = b;
	  for(k=1;k<NB_MAX_BLOCKS_CFG;k++) already_seen[k] = NULL;
	  int clear_path1=block_path_without_redef_end(var_asso->var,def_block,def_stmt); 
	  int clear_path2=cfg_path_without_redef(cfg,var_asso->var,def_block,b,info_out,already_seen);
	  int clear_path3=block_path_without_redef_start(var_asso->var,b,stmt);
	  if (clear_path1 && clear_path2 && clear_path3) {
	    du_asso = (def_use_association*) malloc(sizeof(def_use_association)); 
	    du_asso->var = var_asso->var;
	    du_asso->def_statement = def_stmt;
	    du_asso->use_statement = stmt;
	    du_info->def_use_asso[nb_def_uses] = du_asso;
	    nb_def_uses++;         // ajout d'une asso def_use inter blocs ou intra-bloc avec boucle
	  } 
	}
      else printf("\n\nError block not find with def_stmt->name !!\n\n");
      ind_def_stmt = present_def_block(var_asso->var,du_info->def_in,ind_def_stmt+1);  
    }
    //code utile pour (re)calculer les def-uses locales
    ind_def_stmt = last_def_block(cfg,ib,var_asso->var,stmt);
    if (ind_def_stmt != -1) {
      def_stmt = b->statements[ind_def_stmt];
      du_asso = (def_use_association*) malloc(sizeof(def_use_association)); 
      du_asso->var = var_asso->var;
      du_asso->def_statement = def_stmt;
      du_asso->use_statement = stmt;
      if (!search_def_use_asso(du_asso,du_info->def_use_asso)) {
	du_info->def_use_asso[nb_def_uses] = du_asso;
	nb_def_uses++;
      }
    }  
    i++;
  }
}


// calcule une itération de l'info def_use au niveau global pour tout le cfg
void algo_def_uses_global(cfg_type* cfg, info_out_cfg info_out) {
  int i;                       
  for(i=0;i<(cfg->nb_blocks);i++) 
    algo_block_global(cfg,info_out,i);   
}


// calcule l'info def_use complète au niveau global pour tout le cfg
void algo_global(cfg_type* cfg, info_out_cfg info_out) {
  int i,j,p,boucle=1,num_iter=1,v;
  def_use_info* dui;
  info_out_cfg info_sauv;
  printf("\n\n-> global algo \n");

  // init info_out à vide
  for(i=0;i<(cfg->nb_blocks);i++) {
    dui = (def_use_info*) malloc(sizeof(def_use_info)); 
    info_out[i] = dui; 
    for(j=0;j<MAX_DEF;j++) {
      info_out[i]->def_in[j]=NULL;        
      info_out[i]->def_out[j]=NULL;          
    }  
    for(j=0;j<MAX_USE;j++) info_out[i]->use_out[j]=NULL;        
    for(j=0;j<MAX_DEF_USE;j++) info_out[i]->def_use_asso[j]=NULL;        
  }
  for(i=cfg->nb_blocks;i<NB_MAX_BLOCKS_CFG;i++) info_out[i]=NULL;  
                  
  algo_def_uses_local(cfg,info_sauv);
  print_info_def_uses(cfg,info_sauv);
  
  // sauvegarde uniquement des defs (in et out)
  for(i=0;i<(cfg->nb_blocks);i++) 
    for(j=0;j<MAX_DEF;j++) {
      info_out[i]->def_in[j] = info_sauv[i]->def_in[j];
      info_out[i]->def_out[j] = info_sauv[i]->def_out[j];  
    }

  while (boucle) {
    // maj des def_in avec blocs prédécesseurs
    for(i=0;i<(cfg->nb_blocks);i++) {
      j=0;
      while ((j<MAX_NB_PREVIOUS_NODES_STATEMENT)&&(cfg->blocks[i]->previous_nodes[j] != NULL)) {
	p=search_block_in_cfg(cfg,cfg->blocks[i]->previous_nodes[j]);
	if (p != -1) info_add_defs_in(info_out,i,p);
	j++;        
      }}
      
    algo_def_uses_global(cfg,info_out);
    printf("\n\n     -> global algo - iteration %d \n",num_iter);
    num_iter++;
    print_info_def_uses(cfg,info_out);
    printf("One touch please...\n");
    char c=getchar();
    boucle = !point_fixe(cfg,info_out,info_sauv);
    // sauvegarde uniquement des defs (in et out)
    for(i=0;i<(cfg->nb_blocks);i++) {
      for(j=0;j<MAX_DEF;j++) {
	info_sauv[i]->def_in[j] = info_out[i]->def_in[j];
	info_sauv[i]->def_out[j] = info_out[i]->def_out[j];  
      }
    }    
  }
}


int main(void)
{
  cfg_type *cfg;
  info_out_cfg tab_def_use_assos;
  char c;
  int n=0;
 
  while ((n<=0)||(n>4)) 
    {
      printf("Program to analyse: \n");
      printf("     - example program: 1\n");
      printf("     - exo4_5 TD8 program: 2\n");
      printf("     - exo6 TD8 program: 3\n");
      printf("     - exo7 TD8 program: 4\n");
      scanf("%d",&n);
      c=getchar();
    } 
 
  switch (n) {
  case 1 : printf("\nCase of the example program\n\n");
    cfg = create_cfg_exemple();
    break;
  case 2 : printf("\nCase of the exo4_5 TD8 program\n\n");
    cfg = create_cfg_exo4_5TD8(); 
    break;
  case 3 : printf("\nCase of the exo6 TD8 program\n\n");
    cfg = create_cfg_exo6TD8();  
    break;
  case 4 : printf("\nCase of the exo7 TD8 program\n\n");
    cfg = create_cfg_exo7TD8(); 
  }
  print_cfg(cfg);
  printf("CFG creation finished\n\n");
 
  printf("One touch please...\n");
  c=getchar();
 
  algo_global(cfg,tab_def_use_assos);
  printf("\n\nGlobal analysis finished\n\n");
 
  print_info_def_uses(cfg,tab_def_use_assos); 
  print_file_info_def_uses(n,cfg,tab_def_use_assos); 
 
  printf("Program finished\n");
  c=getchar();
 
  return 0;
}



