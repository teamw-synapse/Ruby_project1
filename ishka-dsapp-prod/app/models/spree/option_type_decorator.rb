# frozen_string_literal: true

Spree::OptionType.class_eval do
  def option_value_netsuite_mapping
    n = name.downcase
    return 'custitem_ish_matrix_material' if n.include?('material')
    return 'custitem_ish_matrix_chakra' if n.include?('chakra')
    return 'custitem_ish_matrix_designs' if n.include?('designs') || n.include?('design')
    return 'custitem_ish_matrix_colour' if n.include?('colour')
    return 'custitem_ish_matrix_size' if n.include?('size')
    return 'custitem_ish_matrix_print' if n.include?('print')
    return 'custitem_ish_matrix_frangrance' if n.include?('frangrance') || n.include?('fragrance')
    return 'custitem_ish_matrix_zodiac' if n.include?('zodiac')
    return 'custitem_ish_matrix_titles' if n.include?('titles')
    return 'custitem_ish_matrix_style' if n.include?('style')
    return 'custitem_ish_matrix_stone' if n.include?('stone')
    return 'custitem_ish_matrix_flavour' if n.include?('flavour')
    return 'custitem_ish_matrix_shape' if n.include?('shape')
    return 'custitem_ish_matrix_salt_lamp' if n.include?('salt_lamp')

    ''
  end
end
