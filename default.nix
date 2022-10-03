{
  writers,
  writeText,
  pandoc,
  browser-sync,
  revealJs,
  git,
}: rec {
  slides-init = writers.writeBashBin "slides-init" ''
    TITLE=''${*:-Cool Presentation}
    export LC_TIME=''${LC_TIME:-de_CH}
    cat <<EOF
    ---
    title: $TITLE
    author: $(git config user.name)
    date: $(date +%x)
    hash: true # good for development/reload
    theme: moon
    ---

    # Fancy section of <br> $TITLE

    ## Superbe content

    this is just **cool**
    EOF
  '';

  # build slides using pandoc.
  slides-build = writers.writeBashBin "slides-build" ''
    DOCUMENT=$1
    if [ ! -r "$DOCUMENT" ]; then
      echo "usage: $(basename $0) <slides.md> [additional pandoc arguments]"
      echo ""
      echo "compiles markdown as reveal js presentation '<slides.md>.html'"
      exit 1
    fi
    shift
    ${pandoc}/bin/pandoc -t revealjs -V revealjs-url=${revealJs} -s -o "$DOCUMENT".html "$DOCUMENT" $@
  '';

  slides-selfcontained = writers.writeBashBin "slides-selfcontained" ''
    DOCUMENT=$1; shift
    ${slides-build}/bin/slides-build $DOCUMENT --self-contained $@
    # --css ./css/print/paper.css
  '';

  # currently not working: decktape not installed, some formatting issues
  slides-pdf = writers.writeBashBin "slides-pdf" ''
    DOCUMENT=$1; shift
    HTML=$DOCUMENT.html
    # 10214x768: https://github.com/astefanutti/decktape/issues/127
    # 16:9 => 1920 x 1080,  16:10 => 1920x1200
    decktape -s 1920x1200 -p 10 $HTML $DOCUMENT.pdf
  '';

  slides-preview = writers.writeBashBin "slides-preview" ''
    DOCUMENT=$1
    HTML=$DOCUMENT.html
    export SLIDES_REBUILD="${slides-build}/bin/slides-build $*"

    echo "# watching for output changes and update slides"
    ${browser-sync}/bin/browser-sync \
      start --config ${bs-config} $DOCUMENT \
      2>&1 >/dev/null &
    BSPID=$!
    trap "kill $BSPID" EXIT

    vim $DOCUMENT

    echo "compute a final self contained html"
    $SLIDES_REBUILD --self-contained
    echo "completed: open $HTML"

    # create pdf after finishing editing
    # ${slides-pdf}/bin/slides-pdf $DOCUMENT > /dev/null 2&>/dev/null &
  '';

  bs-config = writeText "bs-config" ''
    const markdownInput = process.argv[process.argv.length-1];
    const execSync = require('child_process').execSync;
    function build() {
      console.log('rebuild html file: ');
      console.log('result', execSync("$SLIDES_REBUILD"));
    }
    build()
    module.exports = {
      "files": [
        `''${markdownInput}.html`,
        "**/*.css",
        { match: [markdownInput], fn: function (event, file) { build() } },
      ],
      "server": {
        index: `''${markdownInput}.html`,
        routes: { "${revealJs}": "${revealJs}" }
      }
    };
  '';
}
