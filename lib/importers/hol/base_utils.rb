class Importers::Hol::BaseUtils
# does this: details_hash['orig_desc']['author_extended'][0]['initials']
# from this: extract details_hash, ["orig_desc", "author_extended", 0, "initials"]
# and does puts on exceptions


  def extract hash, hash_key_array
    if (hash.nil?)
      return nil
    end
    hash_key = hash_key_array.shift
    ret_val = hash[hash_key]
    if ret_val.nil?
      print_char("#")
      #puts "Unable to extract " + hash_key.to_s
    end
    if (hash_key_array.length == 0)
      return ret_val
    else
      return extract ret_val, hash_key_array
    end
  end


  @@print_char = 0


  def print_char char
    if @@print_char>=80
      @@print_char=0
      puts char
    else
      print char
      @@print_char = @@print_char + 1
    end

  end

  def print_string p_string
    p_string = " " + p_string.to_s + " "
    if @@print_char>=80
      @@print_char=0
      puts p_string
    else
      print p_string
    end
    @@print_char = @@print_char + p_string.length


  end

end
