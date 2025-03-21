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
	$myConnection->disconnect;
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
		goto main_menu;
	}					
}




sub set_lease_details {
	my ($tenant_id, $floor) = @_;

	my $lease_price = 0;
	my $additional_charge = 0;
	my $add_charge_reason = "";
	

	
	if ($floor == 1) {
		$lease_price = 10000;
		
	} elsif ($floor == 2) {
		$lease_price = 12500;
		
	} elsif ($floor == 3) {
		$lease_price = 15000;
		
	} elsif ($floor == 4) {
		$lease_price = 17500;
		
	} elsif ($floor == 5) {
		$lease_price = 20000;
		
	}
	
	my $rand_num = int(rand(5 - 1));
	if($rand_num == 1){$additional_charge = 4500; $add_charge_reason = "PLUMBING REPAIR";}
	elsif($rand_num == 2){$additional_charge = 3000; $add_charge_reason = "FLOOR REPAIR";}
	elsif($rand_num == 3){$additional_charge = 2000; $add_charge_reason = "WALL REPAINT";}
	elsif($rand_num == 4){$additional_charge = 3500; $add_charge_reason = "APPLIANCES REPAIR";}
	else {$additional_charge = "N/A"; $add_charge_reason = "N/A";}

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
			main_menu:
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
				choice3_start:
				system('cls');
				print("-------------------------------------------------------------------");
				print("\n\t\t   Tenant Logs Updater Menu\n");
				db_display();
				print("\nWhich Tenant would you like to make modifications?\nEnter '000' to Return to Menu...\n\n");
				print(">> Enter Tenant ID: ");
				
				# asks for either tenant id/name
				my $tenant_id = <STDIN>;
				chomp($tenant_id);
				registration_check($tenant_id);
				
				my $query = $myConnection->prepare("select exists (select * from tenants where tenant_id= ?)");
				$query->execute($tenant_id);
				my $exists = $query->fetchrow_array;

				# if tenant id/name does not exist
				if (!$exists) {
					print("\n-------------------------------------------------------------------");
					print("\nERROR | Invalid Tenant ID. Please try again.");
					sleep 2.5;
					goto choice3_start;
				} 
				
				modif_prompt:
					my $query = $myConnection->prepare("select full_name from tenants where (tenant_id = ?)");
					$query->execute($tenant_id);
					my $tenant_name = $query->fetchrow_array;
					system('cls');
					print("-------------------------------------------------------------------");
					print("\n\t\t   Update Tenant Information Form\n");
					print("\t\t[ Updating Tenant ", $tenant_name, "'s information ]\n");
					print("-------------------------------------------------------------------\n");
					
					print("\nWhich would you like to update?\n\n[1] Tenant Name\n[2] Tenent Residence\n[0] Back");
					print("\n\n>> Enter Choice: ");
					my $upd_choice = <STDIN>;
					chomp($upd_choice);
					if ($upd_choice == 0) {goto choice3_start};
					if ($upd_choice == 1){
						print("\nEnter your new full name: ");
						my $full_name = <STDIN>;
						chomp($full_name);
						$query = $myConnection->prepare("update tenants set full_name=? where (tenant_id= ?)");
						$query->execute($full_name, $tenant_id);
						system('cls');
						print("Updating Database...");
						sleep 3;
						print("\nSuccessfully Updated Database!");
						sleep 2.5;
						goto modif_prompt;
					}
					
					elsif ($upd_choice == 2) {
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
						goto modif_prompt;
					}
					else {
						print("\n-------------------------------------------------------------------");
						print("\nERROR | Invalid Option. Please try again.");
						sleep 2.5;
						goto modif_prompt
					}
			}
			
			elsif ($menuChoice == 4){
				choice4_start:
				system('cls');
				print("-------------------------------------------------------------------");
				print("\n\t\t      Lease Termination Menu\n");
				db_display();
				
				loop:
					print("\n\tEnter Tenant ID to be Deleted [000 to Cancel]: ");
					my $tenant_id = <STDIN>;
					chomp $tenant_id;
					registration_check($tenant_id);
					# Retrieve the maximum tenant ID from the database
					my $query = $myConnection->prepare('SELECT MAX(tenant_id) FROM tenants');
					$query->execute();
					my ($max_tenant_id) = $query->fetchrow_array();

					if (is_invalid($tenant_id, 1, $max_tenant_id)) {
						print("\n\tError | Tenant ID is Invalid. Please try again.\n");
						sleep 1;
						goto loop;
					}
					else {
						# Check if tenant exists in the database
						my $check = $myConnection->prepare('SELECT COUNT(*) FROM tenants WHERE tenant_id = ?');
						$check->execute($tenant_id);
						my ($count) = $check->fetchrow_array();

						if ($count == 0) {
							print("\n\tError | Tenant does not exist.\n");
							sleep 1;
							goto loop;
						}
						else {
							# Delete tenant from the tenants table
							my $delete = $myConnection->prepare('DELETE FROM tenants WHERE tenant_id = ?');
							$delete->execute($tenant_id);

							# Delete tenant from the lease table
							my $delete_lease = $myConnection->prepare('DELETE FROM lease WHERE tenant_id = ?');
							$delete_lease->execute($tenant_id);

							print("\n\tTenant Record Successfully Deleted!\n");
							sleep 1;
							goto choice4_start;
						}
					}
				
			}
				
			elsif ($menuChoice == 5){
				choice5_start:
				system('cls');
				print("-------------------------------------------------------------------");
				print("\n\t\t    Display Summary of Rent Records\n");
				db_display();
				print("\nWhich Tenant would you like to display Rent Computations?\nEnter '000' to Return to Menu...\n\n");
				print(">> Enter Tenant ID: ");

				my $tenant_id = <STDIN>;
				chomp($tenant_id);
				registration_check($tenant_id);
				my $query = $myConnection->prepare("select exists (select * from tenants where tenant_id= ?)");
				$query->execute($tenant_id);
				my $exists = $query->fetchrow_array;

				if (!$exists) {
					print("\n\tError | Invalid Tenant ID. Please try again.\n");
					sleep 1;
					goto choice5_start;
				}
				my $total_rent = 0;
				$query = $myConnection->prepare("select base_rent from lease where tenant_id = CAST(? AS INTEGER)");
				$query->execute($tenant_id);
				my $base_rent = $query->fetchrow_array;

				$query = $myConnection->prepare("select charge from lease where tenant_id = CAST(? AS INTEGER)");
				$query->execute($tenant_id);
				my $additional_charge = $query->fetchrow_array;
				$additional_charge = $additional_charge // "N/A";
				
				$query = $myConnection->prepare("select charge_type from lease where tenant_id = CAST(? AS INTEGER)");
				$query->execute($tenant_id);
				my $add_charge_reason = $query->fetchrow_array;
				$add_charge_reason = $add_charge_reason // "N/A";
				
				if ($additional_charge eq "N/A") {
					$total_rent = $base_rent;
				} else {
					$total_rent = $base_rent + $additional_charge;
				}
				
				#my $total_rent = $base_rent + $additional_charge;

				system('cls');
				print("-" x 40, "\n");
				print("\t      Rent Summary \n");
				print("-" x 40, "\n");
				print("\nBase Rent: \t\t", $base_rent);
				print("\nExtra Charge: \t\t", $additional_charge);
				print("\nReason: \t\t", $add_charge_reason);
				print("\nTotal Rent: \t\t", $total_rent);
				print("\n\n","-" x 40, "\n");
				print("\nEnter to continue\n");
				<STDIN>;
				goto choice5_start;
			}
			
		}
		exit_program();
	}
}