<!-- DO NOT EDIT: File generated by docs/Generate.sh -->

NAME
====

Net::Packet::ARP - Interface for decoding ARP packets.

SYNOPSIS
========

    use Net::Packet::ARP :short;

    my $frame = Buf.new([...]);
    my $arp = ARP.decode($frame);

    say sprintf '%s(%s) -> %s(%s): %s',
        $arp.src_hw_addr.Str, $arp.src_proto_addr.Str,
        $arp.dst_hw_addr.Str, $arp.dst_proto_addr.Str,
        $arp.operation;

Prints '66:77:88:99:AA:BB(102.119.136.153) -> 00:11:22:33:44:55(0.17.34.51): Request'

EXPORTS
=======

    Net::Packet::ARP
    Net::Packet::ARP::HardwareType
    Net::Packet::ARP::Operation

:short trait adds exports:

    constant ARP               ::= Net::Packet::ARP
    # Implies:
             ARP::HardwareType ::= Net::Packet::ARP::HardwareType
             ARP::Operation    ::= Net::Packet::ARP::Operation

DESCRIPTION
===========

Net::Packet::ARP takes a byte buffer and returns a corresponding packet object. The byte buffer can be of the builtin Buf type or the C_Buf type of Net::Pcap.

enum Net::Packet::ARP::HardwareType
-----------------------------------

    Type to describe the hardware type field of an ARP packet.

enum Net::Packet::ARP::Operation
--------------------------------

    Type to describe the operation field of an ARP packet.

class Net::Packet::ARP
----------------------

    is Net::Packet::Base

### Attributes

     $.hw_type         is rw is Net::Packet::ARP::HardwareType
      Hardware address type field

    $.proto_type      is rw is Net::Packet::EtherType
      Protocol address type field

    $.hw_len          is rw is Int
      Hardware address length field

    $.proto_len       is rw is Int
      Protocol address length field

    $.operation       is rw is Net::Packet::ARP::Operation
      Operation field
       
    $.src_hw_addr     is rw
    $.dst_hw_addr     is rw
    $.src_proto_addr  is rw
    $.dst_proto_addr  is rw
      Sender/Receiver hardware/protocol address fields. Typed with the type
      of address (eg. Net::Packet::IPv4, Net::Packet::MAC_addr).

### Methods

    .decode($frame, Net::Packet::Base $parent?) returns Net::Packet::ARP
      Returns the ARP packet corresponding to $frame.

    .encode()
      Writes to packet to the $.frame buffer.
