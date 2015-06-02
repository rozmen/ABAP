*&---------------------------------------------------------------------*
*& Report  ZRO_TEST76
*& Author : Rıdvan ÖZMEN
*& E-MAIL : rdvanozmen@gmail.com
*& Date   : 27.05.2015  16:28
*&---------------------------------------------------------------------*
*& 
*&
*&---------------------------------------------------------------------*

report  zro_test76.

data :  begin of gs_outtab .
        include structure zro_str_76.
data :  lvc_t_styl type lvc_t_styl.
data :  end  of gs_outtab .

data : ok_code        type sy-ucomm ,
       save_code      type sy-ucomm ,
       g_container    type scrfname value 'EDIT_CONT',
       alv_grid       type ref to  cl_gui_alv_grid   ,
       g_custom_cont  type ref to  cl_gui_custom_container ,
       gs_layout      type lvc_s_layo ,
       alv_fcat       type lvc_t_fcat .

data :  gt_outtab like table of  gs_outtab .

call screen 100 .
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0100 output.
  set pf-status 'MAIN'.
  set titlebar  'MAIN'.

  if g_custom_cont is initial .
    create object g_custom_cont
      exporting
        container_name = g_container.

    create object alv_grid
      exporting
        i_parent = g_custom_cont.

    perform get_data.

    gs_layout-stylefname = 'LVC_T_STYL'.

    call method alv_grid->set_table_for_first_display
      exporting
        i_structure_name = 'ZRO_STR_76'
        is_layout        = gs_layout
      changing
        it_outtab        = gt_outtab[].


     call method alv_grid->set_ready_for_input
                            exporting  i_ready_for_input = 1.



  endif.

endmodule.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form get_data.

  data : begin of lt_mara occurs 0 ,
      matnr	type  matnr ,
      ersda type  ersda ,
      ernam type  ernam ,
      laeda type  laeda ,
      aenam type  aenam ,
      vpsta type  vpsta ,
      pstat type  pstat_d ,
      lvorm type  lvorm ,
      mtart type  mtart ,
      mbrsh type  mbrsh ,
      matkl type  matkl ,
      brgew type  brgew ,
      ntgew type  ntgew ,
  end  of lt_mara .

  data :   lt_lvc_t_styl type lvc_t_styl,
           l_index       type sy-index.

  select matnr ersda ernam  laeda  aenam  vpsta   pstat
         lvorm mtart mbrsh  matkl brgew ntgew
      from mara into  table lt_mara  up to 10 rows .


  loop at lt_mara.
    move-corresponding lt_mara to gs_outtab.
    append gs_outtab to gt_outtab.
    clear gs_outtab.
  endloop.

  loop at gt_outtab into gs_outtab .
    l_index = sy-index.
    refresh lt_lvc_t_styl.
    if gs_outtab-aenam  = 'I021066'.
      perform fill_lvc_t_styl using 'EDIT' changing lt_lvc_t_styl.

    else.
      perform fill_lvc_t_styl using 'NOEDIT' changing lt_lvc_t_styl.
    endif.

    insert lines of lt_lvc_t_styl into table gs_outtab-lvc_t_styl.
    modify gt_outtab from gs_outtab .

  endloop.


endform.                    "get_data

*&---------------------------------------------------------------------*
*&      Form  fill_LVC_T_STYL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE(P_MODE)  text
*      -->LT_LVC_T_STYL  text
*----------------------------------------------------------------------*
form fill_lvc_t_styl using value(p_mode)
                     changing lt_lvc_t_styl type lvc_t_styl.

  data  : ls_lvc_t_styl type lvc_s_styl ,
          l_mode        type raw4.

   data  :  hlp   type string          ,
            struc type dfies-tabname   ,
            fname type dfies-fieldname .

  field-symbols <f> type any .

  if p_mode = 'EDIT'.
    l_mode = cl_gui_alv_grid=>mc_style_enabled.

  elseif p_mode = 'NOEDIT'.
    l_mode = cl_gui_alv_grid=>mc_style_disabled.
  endif.

  do.
    assign component  sy-index of structure gs_outtab to <f>.
    if sy-subrc <> 0. exit. endif.

    describe field <f> help-id hlp.
    split hlp  at '-' into struc fname.

    case fname .
      when 'BRGEW' or 'NTGEW'.
        ls_lvc_t_styl-fieldname = fname.
        ls_lvc_t_styl-style     = l_mode.
        insert ls_lvc_t_styl into table lt_lvc_t_styl.
        clear ls_lvc_t_styl.
      when space.
         continue.
      when others .
        ls_lvc_t_styl-fieldname = fname .
        ls_lvc_t_styl-style     = cl_gui_alv_grid=>mc_style_disabled.
        insert ls_lvc_t_styl into table lt_lvc_t_styl.
        clear ls_lvc_t_styl.
    endcase.

  enddo.



endform .                    "fill_LVC_T_STYL
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0100 input.
  save_code = ok_code.

  case save_code.
    when 'EXIT'.
      leave program .
  endcase .

endmodule.                 " USER_COMMAND_0100  INPUT
