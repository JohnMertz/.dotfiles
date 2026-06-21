PERL5LIB=''
PERL5LIB=$(perl -e 'print join ":",@INC')
export PERL5LIB=$PWD/local/lib/perl5:$(echo $PERL5LIB | sed -r 's#^[^:]+/local/lib/perl5:##')
export PATH=$PWD/local/bin:$(echo $PATH | sed -r 's#^[^:]+/local/bin:##')
eval "$(perl -I $HOME/perl5/lib/perl5 -Mlocal::lib)"
