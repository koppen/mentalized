---
title: Announcing r-conomic
date: '2011-08-02 10:45:27 +0200'
mt_id: 2112
categories:
- Rails
- projects
- software
- programming
---
If you have ever tried to integrate with [e-conomic](http://e-conomic.dk) you'll likely recognize that their API comes out pretty high on the [How to make a crappy API checklist](https://mentalized.net/journal/2011/06/24/how-to-make-a-crappy-api/).

Luckily, if you're using Ruby, you can now use the [r-conomic gem](http://rubygems.org/gems/rconomic) to handle SOAP and the other tedious bits for you.

I'll let the [README](https://github.com/lokalebasen/rconomic/blob/master/README.md) do the talking while I head on over to [my Working With Rails profile](http://workingwithrails.com/person/4796-jakob-skjerning) and **finally** check off the "Has published a Ruby gem" checkbox.

<!--more-->

Usage example
-------------

    economic = Economic::Session.new(123456, 'API', 'passw0rd')
    economic.connect

    # Find a debtor:
    debtor = economic.debtors.find(101)

    # Creating a debtor:
    debtor = economic.debtors.build

    debtor.number = economic.debtors.next_available_number
    debtor.debtor_group_handle = { :number => 1 }
    debtor.name = 'Bob'
    debtor.vat_zone = 'HomeCountry' # HomeCountry, EU, Abroad
    debtor.currency_handle = { :code => 'DKK' }
    debtor.price_group_handle = { :number => 1 }
    debtor.is_accessible = true
    debtor.ci_number = '12345678'
    debtor.term_of_payment_handle = { :id => 1 }
    debtor.layout_handle = { :id => 16 }
    debtor.save

    # Create invoice for debtor:
    invoice = economic.current_invoices.build
    invoice.date = Time.now
    invoice.due_date = Time.now + 15
    invoice.exchange_rate = 100
    invoice.is_vat_included = false

    invoice_line = Economic::CurrentInvoiceLine.new
    invoice_line.description = 'Line on invoice'
    invoice_line.unit_handle = { :number => 1 }
    invoice_line.product_handle = { :number => 101 }
    invoice_line.quantity = 12
    invoice_line.unit_net_price = 19.95
    invoice.lines << invoice_line

    invoice.save


How to enable e-conomic API access
----------------------------------

You need to enable API access in e-conomic before you can, well, use the API. Otherwise you'll be getting access denied errors when connecting.

Just follow the instructions on [e-copedia](http://wiki.e-conomic.co.uk/add-on-modules/) to enable the API Add-on module.


It doesn't do everything
------------------------

Not even remotely... For now, limited to a small subset of all the [available operations](https://www.e-conomic.com/secure/api1/EconomicWebService.asmx):

                       | Create | Read | Update
    -------------------+--------+------+-------
    Debtor             | X      | X    | X
    CurrentInvoice     | X      | X    | X
    CurrentInvoiceLine | X      | X    | X


Credits
-------

Sponsored by [Lokalebasen.dk](http://lokalebasen.dk)
