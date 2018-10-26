int main() {
    int teste_int;
    int res_soma_int;
    int res_sub_int;
    int res_mult_int;
    int res_div_int;
    teste_int = 2;
    res_soma_int = teste_int + 2;
    res_sub_int = teste_int - 1;
    res_mult_int = teste_int * 2;
    res_div_int = teste_int / 2;

    float teste_float;
    float res_soma_float;
    float res_sub_float;
    float res_mult_float;
    float res_div_float;
    teste_float = 1.5;
    res_soma_float = teste_float + 0.5;
    res_sub_float = teste_float - 0.5;
    res_mult_float = teste_float * 2.0;
    res_div_float = teste_float / 2.0;

    int teste_coersao;
    teste_coersao = teste_float + teste_int;

    boolean teste_bool;
    teste_bool = true;
    teste_bool = teste_float > teste_int;
    teste_bool = teste_float < teste_int;

    int teste_escopo;
    teste_escopo = 0;
    {
        teste_escopo = 1;
    }

    float teste_cast_explicito;
    teste_cast_explicito = (float) teste_int;
    
    char teste_char;
    
}