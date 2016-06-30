# coding: utf-8
require "greek_stemmer/version"
require "yaml"

# Please note that we use only upcase letters for all methods. One should
# normalize input streams before using the `stem` method. Normalization means
# detone and upcase.
module GreekStemmer
  extend self

  # Helper method for loading settings
  #
  # @param key [String] the key
  def load_settings(key)
    config_path = File.expand_path("../../config/stemmer.yml", __FILE__)

    begin
      YAML.load_file(config_path)[key]
    rescue => e
      raise "Please provide a valid config/stemmer.yml file, #{e}"
    end
  end

  # Transformations for step 1 words
  STEP_1_EXCEPTIONS = load_settings("step_1_exceptions")

  # Protected words
  PROTECTED_WORDS   = load_settings("protected_words")

  # Regular expression that checks if the word contains only Greek characters
  ALPHABET = Regexp.new("^[ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ]+$").freeze

  # Stems Greek words
  #
  # @param  word  [String]  the word to be stemmed
  # @return       [String]  the stemmed word
  def stem(word)
    return word if word.length < 3
    stem = word.dup
    return stem if PROTECTED_WORDS.include?(stem) || !greek?(word)

    step_1_regexp = /(.*)(#{STEP_1_EXCEPTIONS.keys.join("|")})$/u

    # step 1
    stem.scan(step_1_regexp) do |st, suffix|
      stem = st + STEP_1_EXCEPTIONS[suffix]
    end

    # step 2a
    stem.scan(/^(.+?)(ΑΔΕΣ|ΑΔΩΝ)$/u) do |st, suffix|
      stem = st
      stem << "ΑΔ" unless st =~ /(ΟΚ|ΜΑΜ|ΜΑΝ|ΜΠΑΜΠ|ΠΑΤΕΡ|ΓΙΑΓΙ|ΝΤΑΝΤ|ΚΥΡ|ΘΕΙ|
                                  ΠΕΘΕΡ|ΜΟΥΣΑΜ|ΚΑΠΛΑΜ|ΠΑΡ|ΨΑΡ|ΤΖΟΥΡ|ΤΑΜΠΟΥΡ)$/ux
    end

    # step 2b
    stem.scan(/^(.+?)(ΕΔΕΣ|ΕΔΩΝ)$/u) do |st, suffix|
      stem = st
      stem << "ΕΔ" if st =~ /(ΟΠ|ΙΠ|ΕΜΠ|ΥΠ|ΓΗΠ|ΔΑΠ|ΚΡΑΣΠ|ΜΙΛ)$/u
    end

    # step 2c
    stem.scan(/^(.+?)(ΟΥΔΕΣ|ΟΥΔΩΝ)$/u) do |st, suffix|
      stem = st
      stem << "ΟΥΔ" if st =~ /(ΑΡΚ|ΚΑΛΙΑΚ|ΠΕΤΑΛ|ΛΙΧ|ΠΛΕΞ|ΣΚ|Σ|ΦΛ|ΦΡ|ΒΕΛ|ΛΟΥΛ|ΧΝ|
                               ΣΠ|ΤΡΑΓ|ΦΕ)$/ux
    end

    # step 2d
    stem.scan(/^(.+?)(ΕΩΣ|ΕΩΝ|ΕΑΣ|ΕΑ)$/u) do |st, suffix|
      stem = st
      stem << "Ε" if st =~ /^(Θ|Δ|ΕΛ|ΓΑΛ|Ν|Π|ΙΔ|ΠΑΡ|ΣΤΕΡ|ΟΡΦ|ΑΝΔΡ|ΑΝΤΡ)$/u
    end

    # step 3a
    stem.scan(/^(.+?)(ΕΙΟ|ΕΙΟΣ|ΕΙΟΙ|ΕΙΑ|ΕΙΑΣ|ΕΙΕΣ|ΕΙΟΥ|ΕΙΟΥΣ|ΕΙΩΝ)$/u) do |st, suffix|
      # be conservative with this rule, take care for overstemming.
      stem = st if st.length > 4
    end

    # step 3b
    stem.scan(/^(.+?)(ΙΟΥΣ|ΙΑΣ|ΙΕΣ|ΙΟΣ|ΙΟΥ|ΙΟΙ|ΙΩΝ|ΙΟΝ|ΙΑ|ΙΟ)$/u) do |st, suffix|
      stem  = st
      stem << "Ι" if ends_on_vowel?(st) || st.length < 2 || st=~ /^(ΑΓ|ΑΓΓΕΛ|ΑΓΡ|
                     ΑΕΡ|ΑΘΛ|ΑΚΟΥΣ|ΑΞ|ΑΣ|Β|ΒΙΒΛ|ΒΥΤ|Γ|ΓΙΑΓ|ΓΩΝ|Δ|ΔΑΝ|ΔΗΛ|ΔΗΜ|
                     ΔΟΚΙΜ|ΕΛ|ΖΑΧΑΡ|ΗΛ|ΗΠ|ΙΔ|ΙΣΚ|ΙΣΤ|ΙΟΝ|ΙΩΝ|ΚΙΜΩΛ|ΚΟΛΟΝ|ΚΟΡ|
                     ΚΤΗΡ|ΚΥΡ|ΛΑΓ|ΛΟΓ|ΜΑΓ|ΜΠΑΝ|ΜΠΕΤΟΝ|ΜΠΡ|ΝΑΥΤ|ΝΟΤ|ΟΠΑΛ|ΟΞ|ΟΡ|ΟΣ|
                     ΠΑΝΑΓ|ΠΑΤΡ|ΠΗΛ|ΠΗΝ|ΠΛΑΙΣ|ΠΟΝΤ|ΡΑΔ|ΡΟΔ|ΣΚ|ΣΚΟΡΠ|ΣΟΥΝ|ΣΠΑΝ|
                     ΣΤΑΔ|ΣΥΡ|ΤΗΛ|ΤΙΜ|ΤΟΚ|ΤΟΠ|ΤΡΟΧ|ΦΙΛ|ΦΩΤ|Χ|ΧΙΛ|ΧΡΩΜ|ΧΩΡ)$/ux
      stem << "ΑΙ" if st =~ /^(ΠΑΛ)$/u
    end

    # step 4
    stem.scan(/^(.+?)(ΙΚΟΣ|ΙΚΟΝ|ΙΚΕΙΣ|ΙΚΟΙ|ΙΚΕΣ|ΙΚΟΥΣ|ΙΚΗ|ΙΚΗΣ|ΙΚΟ|ΙΚΑ|ΙΚΟΥ|ΙΚΩΝ|ΙΚΩΣ)$/u) do |st, suffix|
      stem  = st
      stem << "ΙΚ" if ends_on_vowel?(st) || st =~ /^(ΑΔ|ΑΛ|ΑΜΑΝ|ΑΜΕΡ|ΑΜΜΟΧΑΛ|
                      ΑΝΗΘ|ΑΝΤΙΔ|ΑΠΛ|ΑΤΤ|ΑΦΡ|ΒΑΣ|ΒΡΩΜ|ΓΕΝ|ΓΕΡ|Δ|ΔΙΚΑΝ|ΔΥΤ|ΕΙΔ|
                      ΕΝΔ|ΕΞΩΔ|ΗΘ|ΘΕΤ|ΚΑΛΛΙΝ|ΚΑΛΠ|ΚΑΤΑΔ|ΚΟΥΖΙΝ|ΚΡ|ΚΩΔ|ΛΟΓ|Μ|ΜΕΡ|
                      ΜΟΝΑΔ|ΜΟΥΛ|ΜΟΥΣ|ΜΠΑΓΙΑΤ|ΜΠΑΝ|ΜΠΟΛ|ΜΠΟΣ|ΜΥΣΤ|Ν|ΝΙΤ|ΞΙΚ|ΟΠΤ|
                      ΠΑΝ|ΠΕΤΣ|ΠΙΚΑΝΤ|ΠΙΤΣ|ΠΛΑΣΤ|ΠΛΙΑΤΣ|ΠΟΝΤ|ΠΟΣΤΕΛΝ|ΠΡΩΤΟΔ|ΣΕΡΤ|
                      ΣΗΜΑΝΤ|ΣΤΑΤ|ΣΥΝΑΔ|ΣΥΝΟΜΗΛ|ΤΕΛ|ΤΕΧΝ|ΤΡΟΠ|ΤΣΑΜ|ΥΠΟΔ|Φ|ΦΙΛΟΝ|
                      ΦΥΛΟΔ|ΦΥΣ|ΧΑΣ)$/ux || st =~ /(ΦΟΙΝ)$/u
    end

    # step 5a
    stem = "ΑΓΑΜ" if word == 'ΑΓΑΜΕ'

    stem.scan(/^(.+?)(ΑΓΑΜΕ|ΗΣΑΜΕ|ΟΥΣΑΜΕ|ΗΚΑΜΕ|ΗΘΗΚΑΜΕ)$/u) do |st, suffix|
      stem = st
    end

    stem.scan(/^(.+?)(ΑΜΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΑΜ" if st =~ /^(ΑΝΑΠ|ΑΠΟΘ|ΑΠΟΚ|ΑΠΟΣΤ|ΒΟΥΒ|ΞΕΘ|ΟΥΛ|ΠΕΘ|ΠΙΚΡ|ΠΟΤ|
                               ΣΙΧ|Χ)$/ux
    end

    # step 5b
    stem.scan(/^(.+?)(ΑΓΑΝΕ|ΗΣΑΝΕ|ΟΥΣΑΝΕ|ΙΟΝΤΑΝΕ|ΙΟΤΑΝΕ|ΙΟΥΝΤΑΝΕ|ΟΝΤΑΝΕ|ΟΤΑΝΕ|
                      ΟΥΝΤΑΝΕ|ΗΚΑΝΕ|ΗΘΗΚΑΝΕ)$/ux) do |st, suffix|
      stem = st
      stem << "ΑΓΑΝ" if st =~ /^(ΤΡ|ΤΣ)$/u
    end

    stem.scan(/^(.+?)(ΑΝΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΑΝ" if st =~ /^(ΒΕΤΕΡ|ΒΟΥΛΚ|ΒΡΑΧΜ|Γ|ΔΡΑΔΟΥΜ|Θ|ΚΑΛΠΟΥΖ|ΚΑΣΤΕΛ|
                               ΚΟΡΜΟΡ|ΛΑΟΠΛ|ΜΩΑΜΕΘ|Μ|ΜΟΥΣΟΥΛΜ|Ν|ΟΥΛ|Π|ΠΕΛΕΚ|
                               ΠΛ|ΠΟΛΙΣ|ΠΟΡΤΟΛ|ΣΑΡΑΚΑΤΣ|ΣΟΥΛΤ|ΤΣΑΡΛΑΤ|ΟΡΦ|ΤΣΙΓΓ|
                               ΤΣΟΠ|ΦΩΤΟΣΤΕΦ|Χ|ΨΥΧΟΠΛ|ΑΓ|ΟΡΦ|ΓΑΛ|ΓΕΡ|ΔΕΚ|ΔΙΠΛ|
                               ΑΜΕΡΙΚΑΝ|ΟΥΡ|ΠΙΘ|ΠΟΥΡΙΤ|Σ|ΖΩΝΤ|ΙΚ|ΚΑΣΤ|ΚΟΠ|ΛΙΧ|
                               ΛΟΥΘΗΡ|ΜΑΙΝΤ|ΜΕΛ|ΣΙΓ|ΣΠ|ΣΤΕΓ|ΤΡΑΓ|ΤΣΑΓ|Φ|ΕΡ|ΑΔΑΠ|
                               ΑΘΙΓΓ|ΑΜΗΧ|ΑΝΙΚ|ΑΝΟΡΓ|ΑΠΗΓ|ΑΠΙΘ|ΑΤΣΙΓΓ|ΒΑΣ|ΒΑΣΚ|
                               ΒΑΘΥΓΑΛ|ΒΙΟΜΗΧ|ΒΡΑΧΥΚ|ΔΙΑΤ|ΔΙΑΦ|ΕΝΟΡΓ|ΘΥΣ|
                               ΚΑΠΝΟΒΙΟΜΗΧ|ΚΑΤΑΓΑΛ|ΚΛΙΒ|ΚΟΙΛΑΡΦ|ΛΙΒ|ΜΕΓΛΟΒΙΟΜΗΧ|
                               ΜΙΚΡΟΒΙΟΜΗΧ|ΝΤΑΒ|ΞΗΡΟΚΛΙΒ|ΟΛΙΓΟΔΑΜ|ΟΛΟΓΑΛ|ΠΕΝΤΑΡΦ|
                               ΠΕΡΗΦ|ΠΕΡΙΤΡ|ΠΛΑΤ|ΠΟΛΥΔΑΠ|ΠΟΛΥΜΗΧ|ΣΤΕΦ|ΤΑΒ|ΤΕΤ|
                               ΥΠΕΡΗΦ|ΥΠΟΚΟΠ|ΧΑΜΗΛΟΔΑΠ|ΨΗΛΟΤΑΒ)$/ux || ends_on_vowel2?(st)
    end

    # step 5c
    stem.scan(/^(.+?)(ΗΣΕΤΕ)$/u) do |st, suffix|
      stem = st
    end

    stem.scan(/^(.+?)(ΕΤΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΕΤ" if ends_on_vowel2?(st) || st =~ /(ΟΔ|ΑΙΡ|ΦΟΡ|ΤΑΘ|ΔΙΑΘ|ΣΧ|ΕΝΔ|
                      ΕΥΡ|ΤΙΘ|ΥΠΕΡΘ|ΡΑΘ|ΕΝΘ|ΡΟΘ|ΣΘ|ΠΥΡ|ΑΙΝ|ΣΥΝΔ|ΣΥΝ|ΣΥΝΘ|ΧΩΡ|
                      ΠΟΝ|ΒΡ|ΚΑΘ|ΕΥΘ|ΕΚΘ|ΝΕΤ|ΡΟΝ|ΑΡΚ|ΒΑΡ|ΒΟΛ|ΩΦΕΛ)$/ux ||
                      st =~ /^(ΑΒΑΡ|ΒΕΝ|ΕΝΑΡ|ΑΒΡ|ΑΔ|ΑΘ|ΑΝ|ΑΠΛ|ΒΑΡΟΝ|ΝΤΡ|ΣΚ|ΚΟΠ|
                      ΜΠΟΡ|ΝΙΦ|ΠΑΓ|ΠΑΡΑΚΑΛ|ΣΕΡΠ|ΣΚΕΛ|ΣΥΡΦ|ΤΟΚ|Υ|Δ|ΕΜ|ΘΑΡΡ|Θ)$/ux
    end

    # step 5d
    stem.scan(/^(.+?)(ΟΝΤΑΣ|ΩΝΤΑΣ)$/u) do |st, suffix|
      stem = st
      stem << "ΟΝΤ" if st =~ /^ΑΡΧ$/u
      stem << "ΩΝΤ" if st =~ /ΚΡΕ$/u
    end

    # step 5e
    stem.scan(/^(.+?)(ΟΜΑΣΤΕ|ΙΟΜΑΣΤΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΟΜΑΣΤ" if st =~ /^ΟΝ$/u
    end

    # step 5f
    stem.scan(/^(.+?)(ΙΕΣΤΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΙΕΣΤ" if st =~  /^(Π|ΑΠ|ΣΥΜΠ|ΑΣΥΜΠ|ΑΚΑΤΑΠ|ΑΜΕΤΑΜΦ)$/u
    end

    stem.scan(/^(.+?)(ΕΣΤΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΕΣΤ" if st =~  /^(ΑΛ|ΑΡ|ΕΚΤΕΛ|Ζ|Μ|Ξ|ΠΑΡΑΚΑΛ|ΑΡ|ΠΡΟ|ΝΙΣ)$/u
    end

    # step 5g
    stem.scan(/^(.+?)(ΗΘΗΚΑ|ΗΘΗΚΕΣ|ΗΘΗΚΕ)$/u) do |st, suffix|
      stem = st
    end

    stem.scan(/^(.+?)(ΗΚΑ|ΗΚΕΣ|ΗΚΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΗΚ" if st =~ /(ΣΚΩΛ|ΣΚΟΥΛ|ΝΑΡΘ|ΣΦ|ΟΘ|ΠΙΘ)$/u || st =~ /^(ΔΙΑΘ|Θ|
                                                     ΠΑΡΑΚΑΤΑΘ|ΠΡΟΣΘ|ΣΥΝΘ|)$/ux
    end

    # step 5h
    stem.scan(/^(.+?)(ΟΥΣΑ|ΟΥΣΕΣ|ΟΥΣΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΟΥΣ" if st =~ /^(ΦΑΡΜΑΚ|ΧΑΔ|ΑΓΚ|ΑΝΑΡΡ|ΒΡΟΜ|ΕΚΛΙΠ|ΛΑΜΠΙΔ|ΛΕΧ|Μ|
      ΠΑΤ|Ρ|Λ|ΜΕΔ|ΜΕΣΑΖ|ΥΠΟΤΕΙΝ|ΑΜ|ΑΙΘ|ΑΝΗΚ|ΔΕΣΠΟΖ|ΕΝΔΙΑΦΕΡ|ΔΕ|ΔΕΥΤΕΡΕΥ|
      ΚΑΘΑΡΕΥ|ΠΛΕ|ΤΣΑ)$/ux || st =~ /(ΠΟΔΑΡ|ΒΛΕΠ|ΠΑΝΤΑΧ|ΦΡΥΔ|ΜΑΝΤΙΛ|ΜΑΛΛ|ΚΥΜΑΤ|
      ΛΑΧ|ΛΗΓ|ΦΑΓ|ΟΜ|ΠΡΩΤ)$/ux || ends_on_vowel?(st)
    end

    # step 5i
    stem.scan(/^(.+?)(ΑΓΑ|ΑΓΕΣ|ΑΓΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΑΓ" if (st =~ /^(ΑΒΑΣΤ|ΠΟΛΥΦ|ΑΔΗΦ|ΠΑΜΦ|Ρ|ΑΣΠ|ΑΦ|ΑΜΑΛ|ΑΜΑΛΛΙ|
      ΑΝΥΣΤ|ΑΠΕΡ|ΑΣΠΑΡ|ΑΧΑΡ|ΔΕΡΒΕΝ|ΔΡΟΣΟΠ|ΞΕΦ|ΝΕΟΠ|ΝΟΜΟΤ|ΟΛΟΠ|ΟΜΟΤ|ΠΡΟΣΤ|
      ΠΡΟΣΩΠΟΠ|ΣΥΜΠ|ΣΥΝΤ|Τ|ΥΠΟΤ|ΧΑΡ|ΑΕΙΠ|ΑΙΜΟΣΤ|ΑΝΥΠ|ΑΠΟΤ|ΑΡΤΙΠ|ΔΙΑΤ|ΕΝ|ΕΠΙΤ|
      ΚΡΟΚΑΛΟΠ|ΣΙΔΗΡΟΠ|Λ|ΝΑΥ|ΟΥΛΑΜ|ΟΥΡ|Π|ΤΡ|Μ)$/ux || st =~ /(ΟΦ|ΠΕΛ|ΧΟΡΤ|ΛΛ|ΣΦ|
      ΡΠ|ΦΡ|ΠΡ|ΛΟΧ|ΣΜΗΝ)$/ux) && !(st =~ /^(ΨΟΦ|ΝΑΥΛΟΧ)$/u || st =~ /(ΚΟΛΛ)$/u)
    end

    # step 5j
    stem.scan(/^(.+?)(ΗΣΕ|ΗΣΟΥ|ΗΣΑ)$/u) do |st, suffix|
      stem = st
      stem << "ΗΣ" if st =~ /^(Ν|ΧΕΡΣΟΝ|ΔΩΔΕΚΑΝ|ΕΡΗΜΟΝ|ΜΕΓΑΛΟΝ|ΕΠΤΑΝ|Ι)$/u
    end

    # step 5k
    stem.scan(/^(.+?)(ΗΣΤΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΗΣΤ" if st =~ /^(ΑΣΒ|ΣΒ|ΑΧΡ|ΧΡ|ΑΠΛ|ΑΕΙΜΝ|ΔΥΣΧΡ|ΕΥΧΡ|ΚΟΙΝΟΧΡ|
                             ΠΑΛΙΜΨ)$/ux
    end

    # step 5l
    stem.scan(/^(.+?)(ΟΥΝΕ|ΗΣΟΥΝΕ|ΗΘΟΥΝΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΟΥΝ" if st =~ /^(Ν|Ρ|ΣΠΙ|ΣΤΡΑΒΟΜΟΥΤΣ|ΚΑΚΟΜΟΥΤΣ|ΕΞΩΝ)$/u
    end

    # step 5m
    stem.scan(/^(.+?)(ΟΥΜΕ|ΗΣΟΥΜΕ|ΗΘΟΥΜΕ)$/u) do |st, suffix|
      stem = st
      stem << "ΟΥΜ" if st =~ /^(ΠΑΡΑΣΟΥΣ|Φ|Χ|ΩΡΙΟΠΛ|ΑΖ|ΑΛΛΟΣΟΥΣ|ΑΣΟΥΣ)$/u
    end

    # step 6a
    stem.scan(/^(.+?)(ΜΑΤΟΙ|ΜΑΤΟΥΣ|ΜΑΤΟ|ΜΑΤΑ|ΜΑΤΩΣ|ΜΑΤΩΝ|ΜΑΤΟΣ|ΜΑΤΕΣ|ΜΑΤΗ|
                      ΜΑΤΗΣ|ΜΑΤΟΥ)$/ux) do |st, suffix|
      stem = st + "Μ"
      if st =~ /^(ΓΡΑΜ)$/u
        stem << "Α"
      elsif st =~ /^(ΓΕ|ΣΤΑ)$/u
        stem << "ΑΤ"
      end
    end

    # steb 6b
    stem.scan(/^(.+?)(ΟΥΑ)$/ux) do |st, suffix|
      stem = st + 'ΟΥ'
    end

    stem = long_stem_list(stem) if stem.length == word.length

    # step 7
    stem.scan(/^(.+?)(ΕΣΤΕΡ|ΕΣΤΑΤ|ΟΤΕΡ|ΟΤΑΤ|ΥΤΕΡ|ΥΤΑΤ|ΩΤΕΡ|ΩΤΑΤ)$/u) do |st, suffix|
      stem = st unless st =~ /^(ΕΞ|ΕΣ|ΑΝ|ΚΑΤ|Κ|ΠΡ)$/u

      stem = st + "ΥΤ" if st =~ /^(ΚΑ|Μ|ΕΛΕ|ΛΕ|ΔΕ)$/u
    end

    stem
  end

  private

  def ends_on_vowel?(word)
    word =~ /[ΑΕΗΙΟΥΩ]$/u
  end

  def ends_on_vowel2?(word)
    word =~ /[ΑΕΗΙΟΩ]$/u
  end

  def long_stem_list(word)
    word.scan(/^(.+?)(Α|ΑΓΑΤΕ|ΑΓΑΝ|ΑΕΙ|ΑΜΑΙ|ΑΝ|ΑΣ|ΑΣΑΙ|ΑΤΑΙ|ΑΩ|Ε|ΕΙ|ΕΙΣ|ΕΙΤΕ|
    ΕΣΑΙ|ΕΣ|ΕΤΑΙ|Ι|ΙΕΜΑΙ|ΙΕΜΑΣΤΕ|ΙΕΤΑΙ|ΙΕΣΑΙ|ΙΕΣΑΣΤΕ|ΙΟΜΑΣΤΑΝ|ΙΟΜΟΥΝ|ΙΟΜΟΥΝΑ|
    ΙΟΝΤΑΝ|ΙΟΝΤΟΥΣΑΝ|ΙΟΣΑΣΤΑΝ|ΙΟΣΑΣΤΕ|ΙΟΣΟΥΝ|ΙΟΣΟΥΝΑ|ΙΟΤΑΝ|ΙΟΥΜΑ|ΙΟΥΜΑΣΤΕ|
    ΙΟΥΝΤΑΙ|ΙΟΥΝΤΑΝ|Η|ΗΔΕΣ|ΗΔΩΝ|ΗΘΕΙ|ΗΘΕΙΣ|ΗΘΕΙΤΕ|ΗΘΗΚΑΤΕ|ΗΘΗΚΑΝ|ΗΘΟΥΝ|ΗΘΩ|
    ΗΚΑΤΕ|ΗΚΑΝ|ΗΣ|ΗΣΑΝ|ΗΣΑΤΕ|ΗΣΕΙ|ΗΣΕΣ|ΗΣΟΥΝ|ΗΣΩ|Ο|ΟΙ|ΟΜΑΙ|ΟΜΑΣΤΑΝ|ΟΜΟΥΝ|ΟΜΟΥΝΑ|
    ΟΝΤΑΙ|ΟΝΤΑΝ|ΟΝΤΟΥΣΑΝ|ΟΣ|ΟΣΑΣΤΑΝ|ΟΣΑΣΤΕ|ΟΣΟΥΝ|ΟΣΟΥΝΑ|ΟΤΑΝ|ΟΥ|ΟΥΜΑΙ|ΟΥΜΑΣΤΕ|
    ΟΥΝ|ΟΥΝΤΑΙ|ΟΥΝΤΑΝ|ΟΥΣ|ΟΥΣΑΝ|ΟΥΣΑΤΕ|Υ||ΥΑ|ΥΣ|Ω|ΩΝ|ΟΙΣ)$/ux) do |st, suffix|
      word = st
    end
    word
  end

  def greek?(word)
    !! word.match(ALPHABET)
  end
end
