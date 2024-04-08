from pdf2image import convert_from_path


def convert_to_img(pdf_fname):
    pages = convert_from_path(pdf_fname)
    for i, page in enumerate(pages) :
        if i == 0:
            page.save(pdf_fname[0 :-4] + '.jpg', 'JPEG')
        else:
            page.save(pdf_fname[0 :-4] + '_' + str(i) + '.jpg', 'JPEG')
