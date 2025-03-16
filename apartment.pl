#/usr/bin/perl

use strict; use warnings; use DBI;
$| = 1; # Disable output buffering

system("cls");


print("Conneting Database...\n"); sleep 1;

my $myConnection = DBI->connect("DBI:SQLite:dbname=apartmentDB.db", "", "");
print("\nDatabase Connected!\n"); sleep 1; system("cls");

sub exit_program {
	system("cls");
	print("-------------------------------------------------------\n\n");
	print("Thank you for using PERL's Apartment Management System!\n");
	print("Credits to..."); sleep 1;
	print("\n\tOcampo, Hans Christian S."); sleep 1;
	print("\n\tOchoa, Bianca Claire L."); sleep 1;
	print("\n\tOchoa, Bianca Venice L."); sleep 1;
	print("\n\tUrquico, Josef Miko G.\n\n"); sleep 1;
	print("-------------------------------------------------------\n\n");
	sleep 1;
	exit;	
}

sub invalid_message {
	print("\nERROR | Invalid Option. Please try again.\n");
	sleep 2.5;	
}

sub is_invalid {
	my ($choice, $min, $max) = @_; #parameters for args
	return ($choice !~ /^\d+$/ || $choice < $min || $choice > $max); #returns boolean
	#checks whether the $choice is a whole number and whether its below min or above max.
}

sub db_display {
	my $query = $myConnection->prepare('Select * from tenants');
	$query->execute();
	print("-------------------------------------------------------------------");
	print("\n Tenant ID   | Full Name            | Floor Number |  Room Number\n");
	print("-------------------------------------------------------------------\n");
	
	#row is array that holds values of fetchrow_array
	while (my @row = $query->fetchrow_array) {
	printf("%-12s | %-20s | %-12s | %-6s\n", @row), "\n";
	}
	print("-------------------------------------------------------------------\n");
}

sub registration_check {
	my ($a) = @_;
	if ($a eq '000') {
		system("cls");
		print("\nReturning to Main Menu...\n");
		sleep 2.5;
		last;
	}					
}

sub set_lease_details {
	my ($tenant_id, $floor) = @_;

	my $lease_price = 0;
	my $additional_charge = 0;
	my $add_charge_reason = "";

	if ($floor == 1) {
		$lease_price = 10000;
		$additional_charge = 4500;
		$add_charge_reason = "PLUMBING REPAIR"
	} elsif ($floor == 2) {
		$lease_price = 12500;
		$additional_charge = 3500;
		$add_charge_reason = "FLOOR REPAIR"
	} elsif ($floor == 3) {
		$lease_price = 15000;
		$additional_charge = 4500;
		$add_charge_reason = "PLUMBING REPAIR"
	} elsif ($floor == 4) {
		$lease_price = 17500;
		$additional_charge = 3500;
		$add_charge_reason = "FLOOR REPAIR"
	} elsif ($floor == 5) {
		$lease_price = 20000;
		$additional_charge = 4500;
		$add_charge_reason = "PLUMBING REPAIR"
	}

	my $query = $myConnection->prepare("select exists (select * from lease where tenant_id= CAST(? AS INTEGER))");
	$query->execute($tenant_id);
	my $exists = $query->fetchrow_array;

	if (!$exists) {
		$query = $myConnection->prepare("insert into lease (tenant_id, base_rent, charge_type, charge) values (?, ?, ?, ?)");
		$query->execute($tenant_id, $lease_price, $add_charge_reason, $additional_charge);
	} else {
		$query = $myConnection->prepare("update lease set base_rent= CAST(? AS INTEGER), charge_type= ?, charge= CAST(? AS INTEGER) where tenant_id= CAST(? AS INTEGER)");
		$query->execute($lease_price, $add_charge_reason, $additional_charge, $tenant_id);
	}

}

while (1) {
	system("cls");
	print("-----------------------------------------------\n");
	print(" Welcome to PERL's Apartment Management System \n");
	print("-----------------------------------------------\n\n");
	print("[1] Start the Program\n[0] Exit\n\n");
	print("-----------------------------------------------\n");
	print(">> Enter Choice: ");
	my $choice = <STDIN>;
	chomp $choice;
	
	if (is_invalid($choice, 0, 1)) {
		invalid_message();
	}
	
	
	elsif ($choice == 0) {
		exit_program();
	}
	
	elsif ($choice == 1){ #Main Program na to
		
		my $menuChoice = 1;
		
		while (is_invalid($menuChoice, 0, 0)) {
			my $flag = 1;
			system("cls");
			print("--------------------------------\n");
			print(" Apartment Management Main Menu\n");
			print("--------------------------------\n");
			print("\n[1] Tenant Log\n[2] Register Tenant\n[3] Update Tenant Details\n[4] Terminate Lease\n[5] Compute Rent\n[0] Terminate Program\n");
			print("\n--------------------------------");
			print("\n>> Enter Choice: ");
			$menuChoice = <STDIN>;
			chomp $menuChoice;
			
			if (is_invalid($menuChoice, 0, 5)) {
				invalid_message();
				}
				
			elsif ($menuChoice == 1) {
				
				while (1) {
					system("cls");
					print("-----------------------------------");
					print("\n\tList of Tenant Logs");
					print("\n-----------------------------------\n");
					print("\n[1] Display All Tenant Records\n[2] Display Specific Tenant Record\n[0] Return to Main Menu\n");
					print("\n-----------------------------------");
					print("\n>> Enter Choice: ");
					$choice = <STDIN>;
					chomp $choice;
					
					if (is_invalid($choice, 0, 2)) {
						invalid_message();
					}
					
					elsif ($choice == 0) {
					system("cls");
					print("\nReturning to Main Menu...\n");
					sleep 1;
					last;
					}
					
					elsif ($choice == 1){
						system("cls");
						db_display();
						print("\n\tPress any key to continue.");
						<STDIN>;
					}
					
					elsif ($choice == 2) {
						while (1) {
							print("\n>> Enter the Tenant's ID: ");
							my $tenant_id = <STDIN>;
							chomp $tenant_id;
							
							#get number of how many tenants for max.  selectrow_array() combines the prepare, execute, and fetchrow
							my $count = $myConnection->selectrow_array('Select count(*) from tenants');
							
							if (is_invalid($tenant_id, 1, $count)) {
								print("\nERROR | Invalid Tenant ID. Please try again.\n");
							}
							else { 
								#get list of tenants to check if input is in tenants
								my @tenantIdList = $myConnection->selectcol_arrayref('Select tenant_id from tenants');
								
								if (grep($tenant_id, @tenantIdList)) {
									system("cls");
									print("\nFetching Tenant's Records...\n");
									sleep 2;
									print("Tenant Records Fetched!\n\n");
									sleep 1;
									system("cls");
									
									my $query = $myConnection->prepare('Select * from tenants where tenant_id =  ?');
									$query->execute($tenant_id);
									print("-" x 67, "\n");
									print(" Tenant ID   | Full Name            | Floor Number |  Room Number\n");
									print("-" x 67, "\n");
									
									#row is array that holds values of fetchrow_array
									while (my @row = $query->fetchrow_array) {
										printf("%-12s | %-20s | %-12s | %-6s\n", @row), "\n";
									}
									print("-" x 67, "\n");

								}
								last;
							}
						}
				
						#runs after the while loop ends / successful display of tenant
						print("\n\tPress any key to continue.");
						<STDIN>;
					}
				}
			}
			
			
			elsif ($menuChoice == 2){
				while (1) {
					system("cls");
					print("-" x 40, "\n");
					print("\tTenant Registration Menu\n");
					print("-" x 40, "\n\n");
					print(" Please fill out the Registration Form\n Enter '000' to Return to Menu...\n\n");
					print("-" x 40, "\n");
					print("\nTenant Name: ");
					my $full_name = <STDIN>;
					chomp $full_name;
					registration_check($full_name);
				
					print("Floor Number: ");
					my $floor_num = <STDIN>;
					chomp $floor_num;
					registration_check($floor_num);
				
					print("Room Number: ");
					my $room_num = <STDIN>;
					chomp $room_num;
					registration_check($room_num);
					print("\n");
					print("-" x 40, "\n");
					
					#get number of matching names
					my $query = $myConnection->prepare('Select count(*) from tenants where full_name like ?');
					$query->execute("%$full_name%");
					my $count = $query->fetchrow_array();
					
					#get available room per floor: 1 floor has 10 rooms. Max is 5 floors.
					$query= $myConnection->prepare('Select count(*) from tenants where floor_num = ? and room_num = ?');
					$query->execute($floor_num, $room_num);
					my $takenRoom = $query->fetchrow_array();
					
					if ((is_invalid($floor_num, 1, 5)) || (is_invalid($room_num, 1, 10))) {
						print("\nERROR | Room/Floor is Invalid and or Occupied. Please try again.\n");
						sleep 2.5;
					}
					
					elsif ($takenRoom > 0){
						print("\nERROR | Room $room_num in Floor $floor_num is already occupied. Please try again.\n");
						sleep 2.5;
					}
					
					elsif ($count > 0) {
						print("\nERROR | Tenant is already stored in Tenant Logs.\n");
						sleep 2.5;
					}
					
					else {
						# add into tenants
						my $query = $myConnection->prepare('Insert into tenants (full_name, floor_num, room_num) values (?,?,?)'); 
						$query->execute($full_name, $floor_num, $room_num);

						# get new tenant's tenant id
						$query = $myConnection->prepare("select tenant_id from tenants where full_name= ?");
						$query->execute($full_name);
						my $tenant_id = $query->fetchrow;

						# now insert a row in the lease table
						set_lease_details($tenant_id, $floor_num);
						print("\nAdding Tenant to Database...");
						sleep 3;
						print("\nTenant Successfully Added!\n");
						sleep 2.5;
						last;
					}
				}
			}

			# update tenant details
			elsif ($menuChoice == 3){
				choice3:
				system('cls');
				print("-------------------------------------------------------------------");
				print("\n\t\t   Tenant Logs Updater Menu\n");
				db_display();
				print("\nWhich Tenant would you like to make modifications?\n\n");
				print(">> Enter Tenant ID: ");
				
				# asks for either tenant id/name
				my $tenant_id = <STDIN>;
				chomp($tenant_id);
				
				my $query = $myConnection->prepare("select exists (select * from tenants where tenant_id= ?)");
				$query->execute($tenant_id);
				my $exists = $query->fetchrow_array;

				# if tenant id/name does not exist
				if (!$exists) {
					print("\n-------------------------------------------------------------------");
					print("\nERROR | Invalid Tenant ID. Please try again.");
					sleep 2.5;
					goto choice3;
				} 
				
				modif_prompt:
				system('cls');
				print("-------------------------------------------------------------------");
				print("\n\t\t   Update Tenant Information Form\n");
				print("\t\t[ Updating Tenant ", $tenant_id, "'s information ]\n");
				
				#add option to update name.
				print("-------------------------------------------------------------------\n");
				print("\nFloor number: ");
				my $floor_num = <STDIN>;
				#$floor_num += 0;
				chomp($floor_num);

				print("Room number: ");
				my $room_num = <STDIN>;
				#$room_num += 0;
				chomp($room_num);

				# checks if provided floor & room number doesn't exist (meaning, not occupied yet)
				$query = $myConnection->prepare("SELECT EXISTS (SELECT 1 FROM tenants WHERE floor_num = CAST(? AS INTEGER) AND room_num = CAST(? AS INTEGER))");
				$query->execute($floor_num, $room_num);
				$exists = $query->fetchrow_array;

				if ($exists) { # if said room is occupied
					print("\nERROR | Entered room in said floor is already taken. Please try again.");
					sleep 2.5;
					goto modif_prompt;
				} elsif (is_invalid($floor_num, 1, 5) || is_invalid($room_num, 1, 10)) { # if user input is invalid
					print("\nERROR | Entered floor/room is invalid. Please try again.");
					sleep 2.5;
					goto modif_prompt;
				}
				# update tenant floor and room details
				$query = $myConnection->prepare("update tenants set floor_num= ?, room_num= ? where (tenant_id= ?)");
				$query->execute($floor_num, $room_num, $tenant_id);
				# update lease details
				set_lease_details($tenant_id, $floor_num);
				system('cls');
				print("Updating Database...");
				sleep 3;
				print("\nSuccessfully Updated Database!");
				sleep 2.5;

				
			}
			
			elsif ($menuChoice == 4){
				print("\n\nLease Termination Menu\n\n");
				db_display();
				
				while (1){
					print("\n\tEnter Tenant ID to be Deleted [X to Cancel]: ");
					my $tenant_id = <STDIN>;
					chomp $tenant_id;
					
					#get tenant list
					my @tenantIdList = $myConnection->prepare('Select tenant_id from tenants');
					
					#get number of tenants for max
					my $count = $myConnection->selectrow_array('Select count(*) from tenants');
					
					if (uc($tenant_id) eq 'X') {
						print("\n\tReturning to Main Menu...\n");
						sleep 1;
						last;
					}
					
					elsif (is_invalid($tenant_id, 1, $count)) {
						print("\n\tTenant ID is Invalid. Please try again.");
						sleep 1;
						}
					
					elsif ($count == 0){
						print("\n\tTenant does not exist.\n");
						sleep 1;
					}
					else {
						my $delete = $myConnection->prepare('Delete from tenants where tenant_id = ?');
						$delete->execute($tenant_id);

						$delete = $myConnection->prepare('delete from lease where tenant_id = CAST(? AS INTEGER)');
						$delete->execute($tenant_id);
			
						print("\n\tTenant Record Successfully Deleted!\n");
						sleep 1;
					}
				}
			}
				
			elsif ($menuChoice == 5){
				menuChoice5:
				print("\nDisplay Summary of Rent Records");
				db_display();
				print("\nEnter a Tenant ID to display its Rent Computations\n");

				my $tenant_id = <STDIN>;
				chomp($tenant_id);

				my $query = $myConnection->prepare("select exists (select * from tenants where tenant_id= ?)");
				$query->execute($tenant_id);
				my $exists = $query->fetchrow_array;

				if (!$exists) {
					print("\n\tInvalid Tenant ID. Please try again.\n");
					sleep 1;
					goto menuChoice5;
				}

				$query = $myConnection->prepare("select base_rent from lease where tenant_id = CAST(? AS INTEGER)");
				$query->execute($tenant_id);
				my $base_rent = $query->fetchrow_array;

				$query = $myConnection->prepare("select charge from lease where tenant_id = CAST(? AS INTEGER)");
				$query->execute($tenant_id);
				my $additional_charge = $query->fetchrow_array;
				
				$query = $myConnection->prepare("select charge_type from lease where tenant_id = CAST(? AS INTEGER)");
				$query->execute($tenant_id);
				my $add_charge_reason = $query->fetchrow_array;

				my $total_rent = $base_rent + $additional_charge;

				system('cls');
				print("\nRent Summary: ");
				print("\nBase Rent: ");
				print($base_rent);
				print("\nAdditional Charge: ");
				print($additional_charge);
				print("\nReason: ");
				print($add_charge_reason);
				print("\nTotal Rent: ");
				print($total_rent);
				print("\n\nEnter to continue\n");
				<STDIN>;
				system('cls');
			}
			
		}
		exit_program();
	}
}